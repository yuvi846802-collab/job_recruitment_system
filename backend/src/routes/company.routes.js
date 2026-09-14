const express = require('express');
const router = express.Router();
const {
  getCompanies,
  getMyCompany,
  getCompanyById,
  saveCompanyProfile,
  uploadCompanyLogo
} = require('../controllers/company.controller');
const { authenticateToken } = require('../middlewares/auth.middleware');
const { authorizeRoles } = require('../middlewares/role.middleware');
const { uploadLogo } = require('../middlewares/upload.middleware');

router.get('/', getCompanies);
router.get('/my', authenticateToken, authorizeRoles('recruiter', 'admin'), getMyCompany);
router.get('/:id', getCompanyById);
router.post('/', authenticateToken, authorizeRoles('recruiter', 'admin'), saveCompanyProfile);
router.post('/logo', authenticateToken, authorizeRoles('recruiter', 'admin'), uploadLogo.single('logo'), uploadCompanyLogo);

module.exports = router;
