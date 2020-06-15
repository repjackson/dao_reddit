// WebApp.rawConnectHandlers.use(function(req, res, next) {
//   res.setHeader("Access-Control-Allow-Origin", "*");
//   res.setHeader("Access-Control-Allow-Headers", "Authorization,Content-Type");
//   res.setHeader('access-control-allow-origin', '*');
//
//   // Set-Cookie: widget_session=abc123; SameSite=None; Secure
//   // res.cookie('cross-site-cookie', 'bar', { sameSite: 'none', secure: true });
//   // res.setHeader("Set-Cookie", "Secure;SameSite=None");
//   res.setHeader("Set-Cookie", "HttpOnly;Secure;SameSite=None");
//
//
//   return next();
// });
