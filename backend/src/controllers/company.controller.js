const { query } = require('../config/db');

async function getCompanies(req, res, next) {
  try {
    const companies = await query('SELECT * FROM companies ORDER BY company_name ASC');
    return res.json({ success: true, data: companies });
  } catch (error) {
    next(error);
  }
}

async function getMyCompany(req, res, next) {
  try {
    const userId = req.user.id;
    const companies = await query('SELECT * FROM companies WHERE recruiter_id = ?', [userId]);
    if (companies.length === 0) {
      return res.json({ success: true, data: null, message: 'No company registered for this recruiter yet.' });
    }
    return res.json({ success: true, data: companies[0] });
  } catch (error) {
    next(error);
  }
}

async function getCompanyById(req, res, next) {
  try {
    const { id } = req.params;
    const companies = await query('SELECT * FROM companies WHERE id = ?', [id]);
    if (companies.length === 0) {
      return res.status(404).json({ success: false, message: 'Company not found.' });
    }
    const jobs = await query('SELECT * FROM jobs WHERE company_id = ? AND status = "active"', [id]);
    return res.json({ success: true, data: { ...companies[0], active_jobs: jobs } });
  } catch (error) {
    next(error);
  }
}

async function saveCompanyProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const { company_name, description, industry, company_size, website, location, logo_url } = req.body;

    if (!company_name) {
      return res.status(400).json({ success: false, message: 'Company name is required.' });
    }

    const existing = await query('SELECT id FROM companies WHERE recruiter_id = ?', [userId]);

    if (existing.length === 0) {
      const result = await query(
        `INSERT INTO companies (recruiter_id, company_name, logo_url, description, industry, company_size, website, location)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [userId, company_name, logo_url || null, description || null, industry || null, company_size || null, website || null, location || null]
      );
      return res.status(201).json({
        success: true,
        message: 'Company profile created successfully.',
        data: { id: result.insertId }
      });
    } else {
      await query(
        `UPDATE companies 
         SET company_name = ?, logo_url = COALESCE(?, logo_url), description = ?, industry = ?, company_size = ?, website = ?, location = ?
         WHERE recruiter_id = ?`,
        [company_name, logo_url, description, industry, company_size, website, location, userId]
      );
      return res.json({
        success: true,
        message: 'Company profile updated successfully.'
      });
    }
  } catch (error) {
    next(error);
  }
}

async function uploadCompanyLogo(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please select an image file.' });
    }
    const userId = req.user.id;
    const logoUrl = `/uploads/logos/${req.file.filename}`;

    await query('UPDATE companies SET logo_url = ? WHERE recruiter_id = ?', [logoUrl, userId]);

    return res.json({
      success: true,
      message: 'Company logo uploaded.',
      data: { logo_url: logoUrl }
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getCompanies,
  getMyCompany,
  getCompanyById,
  saveCompanyProfile,
  uploadCompanyLogo
};
