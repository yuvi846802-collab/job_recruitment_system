const express = require('express');
const router = express.Router();
const {
  getCandidateProfile,
  updateCandidateProfile,
  uploadCandidateResume,
  addEducation,
  deleteEducation,
  addExperience,
  deleteExperience
} = require('../controllers/candidate.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');
const { uploadResume } = require('../middlewares/upload.middleware');

router.get('/profile', authenticateToken, getCandidateProfile);
router.put('/profile', authenticateToken, authorizeRoles('candidate'), updateCandidateProfile);
router.post('/resume', authenticateToken, authorizeRoles('candidate'), uploadResume.single('resume'), uploadCandidateResume);
router.post('/education', authenticateToken, authorizeRoles('candidate'), addEducation);
router.delete('/education/:id', authenticateToken, authorizeRoles('candidate'), deleteEducation);
router.post('/experience', authenticateToken, authorizeRoles('candidate'), addExperience);
router.delete('/experience/:id', authenticateToken, authorizeRoles('candidate'), deleteExperience);

module.exports = router;
