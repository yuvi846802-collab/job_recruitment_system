const express = require('express');
const router = express.Router();
const { getCategories, createCategory, deleteCategory } = require('../controllers/category.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');

router.get('/', getCategories);
router.post('/', authenticateToken, authorizeRoles('admin'), createCategory);
router.delete('/:id', authenticateToken, authorizeRoles('admin'), deleteCategory);

module.exports = router;
