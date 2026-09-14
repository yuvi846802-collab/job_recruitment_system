const { query } = require('../config/db');

async function getCandidateProfile(req, res, next) {
  try {
    const userId = req.user.id;

    // Get basic user info & job_seeker profile
    const users = await query(
      `SELECT u.id AS user_id, u.email, u.full_name, u.phone, u.role, u.is_active,
              js.id AS seeker_id, js.location, js.bio, js.profile_photo, js.resume_url, js.resume_filename
       FROM users u
       LEFT JOIN job_seekers js ON u.id = js.user_id
       WHERE u.id = ?`,
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ success: false, message: 'Candidate profile not found.' });
    }

    const candidate = users[0];
    const seekerId = candidate.seeker_id;

    let education = [];
    let experience = [];
    let skills = [];

    if (seekerId) {
      education = await query('SELECT * FROM education WHERE seeker_id = ? ORDER BY start_year DESC', [seekerId]);
      experience = await query('SELECT * FROM experience WHERE seeker_id = ? ORDER BY start_date DESC', [seekerId]);
      skills = await query(
        `SELECT s.id, s.skill_name 
         FROM candidate_skills cs
         JOIN skills s ON cs.skill_id = s.id
         WHERE cs.seeker_id = ?`,
        [seekerId]
      );
    }

    return res.json({
      success: true,
      data: {
        ...candidate,
        education,
        experience,
        skills
      }
    });
  } catch (error) {
    next(error);
  }
}

async function updateCandidateProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const { full_name, phone, location, bio } = req.body;

    // Update users table
    if (full_name || phone) {
      await query('UPDATE users SET full_name = COALESCE(?, full_name), phone = COALESCE(?, phone) WHERE id = ?', [
        full_name,
        phone,
        userId
      ]);
    }

    // Ensure seeker entry exists
    let seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      await query('INSERT INTO job_seekers (user_id, location, bio) VALUES (?, ?, ?)', [userId, location || null, bio || null]);
    } else {
      await query('UPDATE job_seekers SET location = COALESCE(?, location), bio = COALESCE(?, bio) WHERE user_id = ?', [
        location,
        bio,
        userId
      ]);
    }

    return res.json({
      success: true,
      message: 'Candidate profile updated successfully.'
    });
  } catch (error) {
    next(error);
  }
}

async function uploadCandidateResume(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please select a resume file (PDF, DOC, DOCX).' });
    }

    const userId = req.user.id;
    const resumeUrl = `/uploads/resumes/${req.file.filename}`;
    const resumeFilename = req.file.originalname;

    let seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      await query('INSERT INTO job_seekers (user_id, resume_url, resume_filename) VALUES (?, ?, ?)', [
        userId,
        resumeUrl,
        resumeFilename
      ]);
    } else {
      await query('UPDATE job_seekers SET resume_url = ?, resume_filename = ? WHERE user_id = ?', [
        resumeUrl,
        resumeFilename,
        userId
      ]);
    }

    return res.json({
      success: true,
      message: 'Resume uploaded successfully.',
      data: {
        resume_url: resumeUrl,
        resume_filename: resumeFilename
      }
    });
  } catch (error) {
    next(error);
  }
}

async function addEducation(req, res, next) {
  try {
    const userId = req.user.id;
    const { degree, institution, field_of_study, start_year, end_year, grade } = req.body;

    if (!degree || !institution) {
      return res.status(400).json({ success: false, message: 'Degree and institution are required.' });
    }

    const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      return res.status(404).json({ success: false, message: 'Candidate profile not found.' });
    }

    const seekerId = seekers[0].id;
    const result = await query(
      'INSERT INTO education (seeker_id, degree, institution, field_of_study, start_year, end_year, grade) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [seekerId, degree, institution, field_of_study || null, start_year || null, end_year || null, grade || null]
    );

    return res.status(201).json({
      success: true,
      message: 'Education record added.',
      data: { id: result.insertId }
    });
  } catch (error) {
    next(error);
  }
}

async function deleteEducation(req, res, next) {
  try {
    const { id } = req.params;
    await query('DELETE FROM education WHERE id = ?', [id]);
    return res.json({ success: true, message: 'Education record deleted.' });
  } catch (error) {
    next(error);
  }
}

async function addExperience(req, res, next) {
  try {
    const userId = req.user.id;
    const { job_title, company_name, location, start_date, end_date, is_current, description } = req.body;

    if (!job_title || !company_name) {
      return res.status(400).json({ success: false, message: 'Job title and company name are required.' });
    }

    const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      return res.status(404).json({ success: false, message: 'Candidate profile not found.' });
    }

    const seekerId = seekers[0].id;
    const result = await query(
      'INSERT INTO experience (seeker_id, job_title, company_name, location, start_date, end_date, is_current, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [seekerId, job_title, company_name, location || null, start_date || null, end_date || null, Boolean(is_current), description || null]
    );


    return res.status(201).json({
      success: true,
      message: 'Experience record added.',
      data: { id: result.insertId }
    });
  } catch (error) {
    next(error);
  }
}

async function deleteExperience(req, res, next) {
  try {
    const { id } = req.params;
    await query('DELETE FROM experience WHERE id = ?', [id]);
    return res.json({ success: true, message: 'Experience record deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getCandidateProfile,
  updateCandidateProfile,
  uploadCandidateResume,
  addEducation,
  deleteEducation,
  addExperience,
  deleteExperience
};
