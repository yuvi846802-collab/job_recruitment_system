const express = require('express');
const router = express.Router();
const {
  getJobs,
  getJobById,
  getMyJobs,
  createJob,
  updateJob,
  deleteJob,
  toggleSaveJob,
  getSavedJobs
} = require('../controllers/job.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');

router.get('/', getJobs);
router.get('/my', authenticateToken, authorizeRoles('recruiter', 'admin'), getMyJobs);
router.get('/saved', authenticateToken, authorizeRoles('candidate'), getSavedJobs);
router.get('/:id', getJobById);
router.post('/', authenticateToken, authorizeRoles('recruiter', 'admin'), createJob);
router.put('/:id', authenticateToken, authorizeRoles('recruiter', 'admin'), updateJob);
router.delete('/:id', authenticateToken, authorizeRoles('recruiter', 'admin'), deleteJob);
router.post('/:id/save', authenticateToken, authorizeRoles('candidate'), toggleSaveJob);

module.exports = router;
