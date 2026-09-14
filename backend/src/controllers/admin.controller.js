const { query } = require('../config/db');

async function getAdminAnalytics(req, res, next) {
  try {
    const totalCandidatesRes = await query("SELECT COUNT(*) AS count FROM users WHERE role = 'candidate'");
    const totalRecruitersRes = await query("SELECT COUNT(*) AS count FROM users WHERE role = 'recruiter'");
    const totalCompaniesRes = await query("SELECT COUNT(*) AS count FROM companies");
    const totalJobsRes = await query("SELECT COUNT(*) AS count FROM jobs");
    const activeJobsRes = await query("SELECT COUNT(*) AS count FROM jobs WHERE status = 'active'");
    const totalApplicationsRes = await query("SELECT COUNT(*) AS count FROM applications");
    const totalInterviewsRes = await query("SELECT COUNT(*) AS count FROM interviews");

    // Application status breakdown
    const appStatusRes = await query(`
      SELECT status, COUNT(*) AS count 
      FROM applications 
      GROUP BY status
    `);

    // Category job breakdown
    const categoryStatsRes = await query(`
      SELECT cat.name AS category, COUNT(j.id) AS job_count
      FROM categories cat
      LEFT JOIN jobs j ON cat.id = j.category_id
      GROUP BY cat.id, cat.name
    `);

    // Selection vs Rejection rate
    const selectedCount = appStatusRes.find(s => s.status === 'Selected')?.count || 0;
    const rejectedCount = appStatusRes.find(s => s.status === 'Rejected')?.count || 0;

    return res.json({
      success: true,
      data: {
        total_candidates: parseInt(totalCandidatesRes[0]?.count || 0, 10),
        total_recruiters: parseInt(totalRecruitersRes[0]?.count || 0, 10),
        total_companies: parseInt(totalCompaniesRes[0]?.count || 0, 10),
        total_jobs: parseInt(totalJobsRes[0]?.count || 0, 10),
        active_jobs: parseInt(activeJobsRes[0]?.count || 0, 10),
        total_applications: parseInt(totalApplicationsRes[0]?.count || 0, 10),
        total_interviews: parseInt(totalInterviewsRes[0]?.count || 0, 10),
        selected_candidates: parseInt(selectedCount || 0, 10),
        rejected_candidates: parseInt(rejectedCount || 0, 10),
        applications_by_status: appStatusRes,
        jobs_by_category: categoryStatsRes
      }
    });
  } catch (error) {
    next(error);
  }
}

async function getAllUsers(req, res, next) {
  try {
    const { role, search } = req.query;
    let sql = 'SELECT id, email, full_name, role, phone, is_active, created_at FROM users WHERE 1=1';
    const params = [];

    if (role && role !== 'all') {
      sql += ' AND role = ?';
      params.push(role);
    }

    if (search) {
      sql += ' AND (full_name LIKE ? OR email LIKE ?)';
      const term = `%${search.trim()}%`;
      params.push(term, term);
    }

    sql += ' ORDER BY created_at DESC';

    const users = await query(sql, params);
    return res.json({ success: true, count: users.length, data: users });
  } catch (error) {
    next(error);
  }
}

async function toggleUserStatus(req, res, next) {
  try {
    const { id } = req.params;
    const { is_active } = req.body;
    const activeBool = Boolean(is_active);

    await query('UPDATE users SET is_active = ? WHERE id = ?', [activeBool, id]);
    return res.json({
      success: true,
      message: `User status changed to ${activeBool ? 'Active' : 'Inactive'}.`
    });

  } catch (error) {
    next(error);
  }
}

module.exports = {
  getAdminAnalytics,
  getAllUsers,
  toggleUserStatus
};
