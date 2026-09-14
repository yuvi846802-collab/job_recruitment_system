const { query } = require('../config/db');

async function getCategories(req, res, next) {
  try {
    const sql = `
      SELECT c.*, COUNT(j.id) AS active_jobs_count
      FROM categories c
      LEFT JOIN jobs j ON c.id = j.category_id AND j.status = 'active'
      GROUP BY c.id
      ORDER BY c.name ASC
    `;
    const categories = await query(sql);
    return res.json({ success: true, data: categories });
  } catch (error) {
    next(error);
  }
}

async function createCategory(req, res, next) {
  try {
    const { name, icon_name = 'work', description } = req.body;
    if (!name) {
      return res.status(400).json({ success: false, message: 'Category name is required.' });
    }

    const result = await query(
      'INSERT INTO categories (name, icon_name, description) VALUES (?, ?, ?)',
      [name.trim(), icon_name, description || null]
    );

    return res.status(201).json({
      success: true,
      message: 'Job category created.',
      data: { id: result.insertId, name, icon_name, description }
    });
  } catch (error) {
    next(error);
  }
}

async function deleteCategory(req, res, next) {
  try {
    const { id } = req.params;
    await query('DELETE FROM categories WHERE id = ?', [id]);
    return res.json({ success: true, message: 'Category deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getCategories,
  createCategory,
  deleteCategory
};
