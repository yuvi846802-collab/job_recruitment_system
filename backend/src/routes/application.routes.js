const express = require('express');
const router = express.Router();
const {
  applyForJob,
  getMyApplications,
  getJobApplicants,
  updateApplicationStatus
} = require('../controllers/application.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');

router.post('/', authenticateToken, authorizeRoles('candidate'), applyForJob);
router.get('/my', authenticateToken, authorizeRoles('candidate'), getMyApplications);
router.get('/job/:jobId', authenticateToken, authorizeRoles('recruiter', 'admin'), getJobApplicants);
router.patch('/:id/status', authenticateToken, authorizeRoles('recruiter', 'admin'), updateApplicationStatus);

module.exports = router;
