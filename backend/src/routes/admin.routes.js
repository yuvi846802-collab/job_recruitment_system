const express = require('express');
const router = express.Router();
const { getAdminAnalytics, getAllUsers, toggleUserStatus } = require('../controllers/admin.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');

router.get('/analytics', authenticateToken, authorizeRoles('admin'), getAdminAnalytics);
router.get('/users', authenticateToken, authorizeRoles('admin'), getAllUsers);
router.patch('/users/:id/status', authenticateToken, authorizeRoles('admin'), toggleUserStatus);

module.exports = router;
