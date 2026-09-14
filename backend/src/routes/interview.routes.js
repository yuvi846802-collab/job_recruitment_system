const express = require('express');
const router = express.Router();
const { scheduleInterview, getMyInterviews, updateInterview } = require('../controllers/interview.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');

router.post('/', authenticateToken, authorizeRoles('recruiter', 'admin'), scheduleInterview);
router.get('/my', authenticateToken, getMyInterviews);
router.patch('/:id', authenticateToken, authorizeRoles('recruiter', 'admin'), updateInterview);

module.exports = router;
