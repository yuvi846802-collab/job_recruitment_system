const { query } = require('../config/db');

async function applyForJob(req, res, next) {
  try {
    const userId = req.user.id;
    const { job_id, cover_letter } = req.body;

    if (!job_id) {
      return res.status(400).json({ success: false, message: 'Job ID is required.' });
    }

    const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      return res.status(400).json({ success: false, message: 'Candidate profile required before applying.' });
    }

    const seekerId = seekers[0].id;

    // Check duplicate
    const existing = await query('SELECT id FROM applications WHERE job_id = ? AND seeker_id = ?', [job_id, seekerId]);
    if (existing.length > 0) {
      return res.status(409).json({ success: false, message: 'You have already applied for this job.' });
    }

    // Insert application
    const result = await query(
      'INSERT INTO applications (job_id, seeker_id, cover_letter, status) VALUES (?, ?, ?, ?)',
      [job_id, seekerId, cover_letter || null, 'Applied']
    );

    // Get job & company info for notifications
    const jobs = await query(
      'SELECT j.title, c.recruiter_id, c.company_name FROM jobs j JOIN companies c ON j.company_id = c.id WHERE j.id = ?',
      [job_id]
    );

    if (jobs.length > 0) {
      const job = jobs[0];
      // Candidate notification
      await query(
        'INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)',
        [userId, 'Application Submitted', `Your application for ${job.title} at ${job.company_name} was received.`, 'success']
      );

      // Recruiter notification
      await query(
        'INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)',
        [job.recruiter_id, 'New Job Applicant', `A candidate applied for ${job.title}.`, 'info']
      );
    }

    return res.status(201).json({
      success: true,
      message: 'Application submitted successfully!',
      data: { application_id: result.insertId }
    });
  } catch (error) {
    next(error);
  }
}

async function getMyApplications(req, res, next) {
  try {
    const userId = req.user.id;
    const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      return res.json({ success: true, data: [] });
    }

    const seekerId = seekers[0].id;
    const sql = `
      SELECT 
        a.id AS application_id, a.status, a.cover_letter, a.applied_at, a.updated_at,
        j.id AS job_id, j.title AS job_title, j.location, j.job_type, j.work_mode, j.salary_min, j.salary_max,
        c.company_name, c.logo_url,
        i.id AS interview_id, i.scheduled_date, i.scheduled_time, i.interview_mode, i.location_or_link, i.interviewer_name
      FROM applications a
      JOIN jobs j ON a.job_id = j.id
      JOIN companies c ON j.company_id = c.id
      LEFT JOIN interviews i ON a.id = i.application_id
      WHERE a.seeker_id = ?
      ORDER BY a.applied_at DESC
    `;

    const apps = await query(sql, [seekerId]);
    return res.json({ success: true, data: apps });
  } catch (error) {
    next(error);
  }
}

async function getJobApplicants(req, res, next) {
  try {
    const { jobId } = req.params;
    const { status } = req.query;

    let sql = `
      SELECT 
        a.id AS application_id, a.status, a.cover_letter, a.applied_at,
        js.id AS seeker_id, js.user_id, js.location AS candidate_location, js.bio, js.resume_url, js.resume_filename,
        u.full_name AS candidate_name, u.email AS candidate_email, u.phone AS candidate_phone,
        j.title AS job_title,
        i.id AS interview_id, i.scheduled_date, i.scheduled_time, i.interview_mode, i.location_or_link
      FROM applications a
      JOIN job_seekers js ON a.seeker_id = js.id
      JOIN users u ON js.user_id = u.id
      JOIN jobs j ON a.job_id = j.id
      LEFT JOIN interviews i ON a.id = i.application_id
      WHERE a.job_id = ?
    `;

    const params = [jobId];
    if (status && status !== 'all') {
      sql += ` AND a.status = ?`;
      params.push(status);
    }

    sql += ` ORDER BY a.applied_at DESC`;

    const applicants = await query(sql, params);
    return res.json({ success: true, count: applicants.length, data: applicants });
  } catch (error) {
    next(error);
  }
}

async function updateApplicationStatus(req, res, next) {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['Applied', 'Under Review', 'Shortlisted', 'Interview Scheduled', 'Selected', 'Rejected'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status value.' });
    }

    await query('UPDATE applications SET status = ? WHERE id = ?', [status, id]);

    // Send notification to candidate
    const apps = await query(
      `SELECT a.seeker_id, js.user_id, j.title, c.company_name 
       FROM applications a 
       JOIN job_seekers js ON a.seeker_id = js.id 
       JOIN jobs j ON a.job_id = j.id 
       JOIN companies c ON j.company_id = c.id 
       WHERE a.id = ?`,
      [id]
    );

    if (apps.length > 0) {
      const app = apps[0];
      const message = `Your application for ${app.title} at ${app.company_name} status was updated to '${status}'.`;
      await query(
        'INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)',
        [app.user_id, 'Application Status Update', message, status === 'Rejected' ? 'warning' : 'success']
      );
    }

    return res.json({ success: true, message: `Application status updated to ${status}.` });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  applyForJob,
  getMyApplications,
  getJobApplicants,
  updateApplicationStatus
};
