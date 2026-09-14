const { query } = require('../config/db');

async function getJobs(req, res, next) {
  try {
    const {
      search,
      category_id,
      location,
      work_mode,
      job_type,
      experience_years,
      salary_min,
      sort_by = 'latest',
      page = 1,
      limit = 100
    } = req.query;

    let sql = `
      SELECT 
        j.id, j.title, j.description, j.responsibilities, j.requirements, 
        j.skills_required, j.experience_years, j.salary_min, j.salary_max, 
        j.job_type, j.work_mode, j.location, j.openings, j.deadline, j.status, j.created_at,
        c.id AS company_id, c.company_name, c.logo_url, c.industry,
        cat.id AS category_id, cat.name AS category_name, cat.icon_name AS category_icon
      FROM jobs j
      JOIN companies c ON j.company_id = c.id
      JOIN categories cat ON j.category_id = cat.id
      WHERE j.status = 'active'
    `;

    const params = [];

    if (search) {
      sql += ` AND (j.title LIKE ? OR j.description LIKE ? OR c.company_name LIKE ? OR j.skills_required LIKE ?)`;
      const term = `%${search.trim()}%`;
      params.push(term, term, term, term);
    }

    if (category_id && category_id !== 'all') {
      sql += ` AND j.category_id = ?`;
      params.push(parseInt(category_id));
    }

    if (location) {
      sql += ` AND j.location LIKE ?`;
      params.push(`%${location.trim()}%`);
    }

    if (work_mode && work_mode !== 'all') {
      sql += ` AND j.work_mode = ?`;
      params.push(work_mode);
    }

    if (job_type && job_type !== 'all') {
      sql += ` AND j.job_type = ?`;
      params.push(job_type);
    }

    if (experience_years) {
      sql += ` AND j.experience_years <= ?`;
      params.push(parseInt(experience_years));
    }

    if (salary_min) {
      sql += ` AND j.salary_max >= ?`;
      params.push(parseFloat(salary_min));
    }

    // Sorting
    if (sort_by === 'salary_high') {
      sql += ` ORDER BY j.salary_max DESC, j.created_at DESC`;
    } else if (sort_by === 'salary_low') {
      sql += ` ORDER BY j.salary_min ASC, j.created_at DESC`;
    } else {
      sql += ` ORDER BY j.created_at DESC`;
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);
    sql += ` LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), parseInt(offset));

    const jobs = await query(sql, params);

    return res.json({
      success: true,
      count: jobs.length,
      page: parseInt(page),
      data: jobs
    });
  } catch (error) {
    next(error);
  }
}

async function getJobById(req, res, next) {
  try {
    const { id } = req.params;
    const userId = req.user ? req.user.id : null;

    const sql = `
      SELECT 
        j.id, j.title, j.description, j.responsibilities, j.requirements, 
        j.skills_required, j.experience_years, j.salary_min, j.salary_max, 
        j.job_type, j.work_mode, j.location, j.openings, j.deadline, j.status, j.created_at,
        c.id AS company_id, c.company_name, c.logo_url, c.description AS company_description, 
        c.website AS company_website, c.industry, c.location AS company_location,
        cat.id AS category_id, cat.name AS category_name
      FROM jobs j
      JOIN companies c ON j.company_id = c.id
      JOIN categories cat ON j.category_id = cat.id
      WHERE j.id = ?
    `;

    const jobs = await query(sql, [id]);
    if (jobs.length === 0) {
      return res.status(404).json({ success: false, message: 'Job posting not found.' });
    }

    const job = jobs[0];
    let isApplied = false;
    let isSaved = false;

    if (userId) {
      const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
      if (seekers.length > 0) {
        const seekerId = seekers[0].id;
        const apps = await query('SELECT id, status FROM applications WHERE job_id = ? AND seeker_id = ?', [id, seekerId]);
        if (apps.length > 0) {
          isApplied = true;
          job.user_application = apps[0];
        }
        const saves = await query('SELECT seeker_id FROM saved_jobs WHERE job_id = ? AND seeker_id = ?', [id, seekerId]);
        isSaved = saves.length > 0;
      }
    }

    return res.json({
      success: true,
      data: {
        ...job,
        is_applied: isApplied,
        is_saved: isSaved
      }
    });
  } catch (error) {
    next(error);
  }
}

async function getMyJobs(req, res, next) {
  try {
    const userId = req.user.id;
    const companies = await query('SELECT id FROM companies WHERE recruiter_id = ?', [userId]);

    if (companies.length === 0) {
      return res.json({ success: true, data: [] });
    }

    const companyId = companies[0].id;
    const sql = `
      SELECT j.*, cat.name AS category_name,
             (SELECT COUNT(*) FROM applications a WHERE a.job_id = j.id) AS applicant_count
      FROM jobs j
      JOIN categories cat ON j.category_id = cat.id
      WHERE j.company_id = ?
      ORDER BY j.created_at DESC
    `;

    const jobs = await query(sql, [companyId]);
    return res.json({ success: true, data: jobs });
  } catch (error) {
    next(error);
  }
}

async function createJob(req, res, next) {
  try {
    const userId = req.user.id;
    const {
      title,
      category_id,
      description,
      responsibilities,
      requirements,
      skills_required,
      experience_years = 0,
      salary_min = 0,
      salary_max = 0,
      job_type = 'Full Time',
      work_mode = 'On-site',
      location,
      openings = 1,
      deadline
    } = req.body;

    if (!title || !category_id || !description || !location) {
      return res.status(400).json({
        success: false,
        message: 'Job title, category, description, and location are required.'
      });
    }

    // Find recruiter company
    let companyId;
    if (req.user.role === 'recruiter') {
      const companies = await query('SELECT id FROM companies WHERE recruiter_id = ?', [userId]);
      if (companies.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Please complete your company profile before posting a job.'
        });
      }
      companyId = companies[0].id;
    } else {
      // Admin posting job
      const companies = await query('SELECT id FROM companies LIMIT 1');
      companyId = companies.length > 0 ? companies[0].id : 1;
    }

    const result = await query(
      `INSERT INTO jobs 
       (company_id, category_id, title, description, responsibilities, requirements, skills_required, 
        experience_years, salary_min, salary_max, job_type, work_mode, location, openings, deadline)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        companyId,
        category_id,
        title,
        description,
        responsibilities || null,
        requirements || null,
        skills_required || null,
        experience_years,
        salary_min,
        salary_max,
        job_type,
        work_mode,
        location,
        openings,
        deadline || null
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Job created successfully.',
      data: { id: result.insertId }
    });
  } catch (error) {
    next(error);
  }
}

async function updateJob(req, res, next) {
  try {
    const { id } = req.params;
    const {
      title,
      category_id,
      description,
      responsibilities,
      requirements,
      skills_required,
      experience_years,
      salary_min,
      salary_max,
      job_type,
      work_mode,
      location,
      openings,
      deadline,
      status
    } = req.body;

    await query(
      `UPDATE jobs SET 
        title = COALESCE(?, title),
        category_id = COALESCE(?, category_id),
        description = COALESCE(?, description),
        responsibilities = COALESCE(?, responsibilities),
        requirements = COALESCE(?, requirements),
        skills_required = COALESCE(?, skills_required),
        experience_years = COALESCE(?, experience_years),
        salary_min = COALESCE(?, salary_min),
        salary_max = COALESCE(?, salary_max),
        job_type = COALESCE(?, job_type),
        work_mode = COALESCE(?, work_mode),
        location = COALESCE(?, location),
        openings = COALESCE(?, openings),
        deadline = COALESCE(?, deadline),
        status = COALESCE(?, status)
       WHERE id = ?`,
      [
        title,
        category_id,
        description,
        responsibilities,
        requirements,
        skills_required,
        experience_years,
        salary_min,
        salary_max,
        job_type,
        work_mode,
        location,
        openings,
        deadline,
        status,
        id
      ]
    );

    return res.json({ success: true, message: 'Job updated successfully.' });
  } catch (error) {
    next(error);
  }
}

async function deleteJob(req, res, next) {
  try {
    const { id } = req.params;
    await query('DELETE FROM jobs WHERE id = ?', [id]);
    return res.json({ success: true, message: 'Job deleted successfully.' });
  } catch (error) {
    next(error);
  }
}

async function toggleSaveJob(req, res, next) {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      return res.status(400).json({ success: false, message: 'Candidate profile required.' });
    }

    const seekerId = seekers[0].id;
    const existing = await query('SELECT seeker_id FROM saved_jobs WHERE seeker_id = ? AND job_id = ?', [seekerId, id]);

    if (existing.length > 0) {
      await query('DELETE FROM saved_jobs WHERE seeker_id = ? AND job_id = ?', [seekerId, id]);
      return res.json({ success: true, message: 'Job removed from saved items.', is_saved: false });
    } else {
      await query('INSERT INTO saved_jobs (seeker_id, job_id) VALUES (?, ?)', [seekerId, id]);
      return res.json({ success: true, message: 'Job saved successfully.', is_saved: true });
    }
  } catch (error) {
    next(error);
  }
}

async function getSavedJobs(req, res, next) {
  try {
    const userId = req.user.id;
    const seekers = await query('SELECT id FROM job_seekers WHERE user_id = ?', [userId]);
    if (seekers.length === 0) {
      return res.json({ success: true, data: [] });
    }

    const seekerId = seekers[0].id;
    const sql = `
      SELECT j.*, c.company_name, c.logo_url, cat.name AS category_name, sj.saved_at
      FROM saved_jobs sj
      JOIN jobs j ON sj.job_id = j.id
      JOIN companies c ON j.company_id = c.id
      JOIN categories cat ON j.category_id = cat.id
      WHERE sj.seeker_id = ?
      ORDER BY sj.saved_at DESC
    `;

    const jobs = await query(sql, [seekerId]);
    return res.json({ success: true, data: jobs });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getJobs,
  getJobById,
  getMyJobs,
  createJob,
  updateJob,
  deleteJob,
  toggleSaveJob,
  getSavedJobs
};
