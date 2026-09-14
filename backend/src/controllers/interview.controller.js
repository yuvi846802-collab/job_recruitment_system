const { query } = require('../config/db');

async function scheduleInterview(req, res, next) {
  try {
    const { application_id, scheduled_date, scheduled_time, interview_mode = 'Online', location_or_link, interviewer_name, notes } = req.body;

    if (!application_id || !scheduled_date || !scheduled_time || !location_or_link || !interviewer_name) {
      return res.status(400).json({
        success: false,
        message: 'Application ID, date, time, location/link, and interviewer name are required.'
      });
    }

    // Check existing interview
    const existing = await query('SELECT id FROM interviews WHERE application_id = ?', [application_id]);

    let interviewId;
    if (existing.length > 0) {
      interviewId = existing[0].id;
      await query(
        `UPDATE interviews SET 
          scheduled_date = ?, scheduled_time = ?, interview_mode = ?, location_or_link = ?, interviewer_name = ?, notes = ?, status = 'Rescheduled'
         WHERE id = ?`,
        [scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes || null, interviewId]
      );
    } else {
      const result = await query(
        `INSERT INTO interviews (application_id, scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, 'Scheduled')`,
        [application_id, scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes || null]
      );
      interviewId = result.insertId;
    }

    // Update application status to 'Interview Scheduled'
    await query("UPDATE applications SET status = 'Interview Scheduled' WHERE id = ?", [application_id]);

    // Send notification to candidate
    const apps = await query(
      `SELECT a.seeker_id, js.user_id, j.title, c.company_name 
       FROM applications a 
       JOIN job_seekers js ON a.seeker_id = js.id 
       JOIN jobs j ON a.job_id = j.id 
       JOIN companies c ON j.company_id = c.id 
       WHERE a.id = ?`,
      [application_id]
    );

    if (apps.length > 0) {
      const app = apps[0];
      await query(
        'INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)',
        [
          app.user_id,
          'Interview Scheduled!',
          `An interview has been scheduled for your application to ${app.title} on ${scheduled_date} at ${scheduled_time}.`,
          'info'
        ]
      );
    }

    return res.status(201).json({
      success: true,
      message: 'Interview scheduled successfully.',
      data: { interview_id: interviewId }
    });
  } catch (error) {
    next(error);
  }
}

async function getMyInterviews(req, res, next) {
  try {
    const userId = req.user.id;
    const userRole = req.user.role;

    let sql = '';
    let params = [];

    if (userRole === 'candidate') {
      sql = `
        SELECT 
          i.*, a.status AS application_status,
          j.title AS job_title, j.location AS job_location,
          c.company_name, c.logo_url
        FROM interviews i
        JOIN applications a ON i.application_id = a.id
        JOIN job_seekers js ON a.seeker_id = js.id
        JOIN jobs j ON a.job_id = j.id
        JOIN companies c ON j.company_id = c.id
        WHERE js.user_id = ?
        ORDER BY i.scheduled_date ASC, i.scheduled_time ASC
      `;
      params = [userId];
    } else if (userRole === 'recruiter') {
      sql = `
        SELECT 
          i.*, a.status AS application_status,
          u.full_name AS candidate_name, u.email AS candidate_email, u.phone AS candidate_phone,
          j.title AS job_title, c.company_name
        FROM interviews i
        JOIN applications a ON i.application_id = a.id
        JOIN job_seekers js ON a.seeker_id = js.id
        JOIN users u ON js.user_id = u.id
        JOIN jobs j ON a.job_id = j.id
        JOIN companies c ON j.company_id = c.id
        WHERE c.recruiter_id = ?
        ORDER BY i.scheduled_date ASC, i.scheduled_time ASC
      `;
      params = [userId];
    } else {
      // Admin sees all
      sql = `
        SELECT 
          i.*, a.status AS application_status,
          u.full_name AS candidate_name, u.email AS candidate_email,
          j.title AS job_title, c.company_name
        FROM interviews i
        JOIN applications a ON i.application_id = a.id
        JOIN job_seekers js ON a.seeker_id = js.id
        JOIN users u ON js.user_id = u.id
        JOIN jobs j ON a.job_id = j.id
        JOIN companies c ON j.company_id = c.id
        ORDER BY i.scheduled_date ASC, i.scheduled_time ASC
      `;
    }

    const interviews = await query(sql, params);
    return res.json({ success: true, data: interviews });
  } catch (error) {
    next(error);
  }
}

async function updateInterview(req, res, next) {
  try {
    const { id } = req.params;
    const { scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status } = req.body;

    await query(
      `UPDATE interviews SET 
        scheduled_date = COALESCE(?, scheduled_date),
        scheduled_time = COALESCE(?, scheduled_time),
        interview_mode = COALESCE(?, interview_mode),
        location_or_link = COALESCE(?, location_or_link),
        interviewer_name = COALESCE(?, interviewer_name),
        notes = COALESCE(?, notes),
        status = COALESCE(?, status)
       WHERE id = ?`,
      [scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status, id]
    );

    return res.json({ success: true, message: 'Interview details updated successfully.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  scheduleInterview,
  getMyInterviews,
  updateInterview
};
