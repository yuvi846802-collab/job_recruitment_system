function authorizeRoles(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized. User authentication required.'
      });
    }

    const userRole = req.user.role;
    // Map role aliases: 'hr' <-> 'recruiter', 'user' <-> 'candidate'
    const equivalentRoles = [userRole];
    if (userRole === 'recruiter') equivalentRoles.push('hr');
    if (userRole === 'hr') equivalentRoles.push('recruiter');
    if (userRole === 'candidate') equivalentRoles.push('user');
    if (userRole === 'user') equivalentRoles.push('candidate');

    const hasPermission = allowedRoles.some(role => equivalentRoles.includes(role));

    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        message: `Forbidden. Role '${userRole}' does not have permission to access this resource.`
      });
    }

    next();
  };
}

module.exports = {
  authorizeRoles
};
