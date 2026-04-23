package controller;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginVerifyOTPServlet")
public class LoginVerifyOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String enteredOtp = request.getParameter("otp");
        HttpSession session = request.getSession();

        String realOtp = (String) session.getAttribute("loginOtp");
        Long expiry = (Long) session.getAttribute("loginOtpExpiry");

        if(realOtp == null || expiry == null){
            response.sendRedirect("login.jsp");
            return;
        }

        if(System.currentTimeMillis() > expiry){
            response.sendRedirect("login_otp_verification.jsp?error=expired");
            return;
        }

        if(realOtp.equals(enteredOtp)){
            // OTP verified
            int userId = (Integer) session.getAttribute("loginOtpUserId");
            int roleId = (Integer) session.getAttribute("loginOtpRoleId");
            String email = (String) session.getAttribute("loginOtpEmail");
            String forceChange = (String) session.getAttribute("forceChange");

            // Set session for authenticated user
            session.setAttribute("user_id", userId);
            session.setAttribute("role_id", roleId);
            session.setAttribute("email", email);

            // Remove OTP session attributes
            session.removeAttribute("loginOtp");
            session.removeAttribute("loginOtpExpiry");
            session.removeAttribute("loginOtpVerified");

            // Check if first login (temporary password)
            if("Y".equals(forceChange)){
                response.sendRedirect("set_new_password.jsp");
            } else {
                // Redirect to appropriate dashboard
                if (roleId == 1)
                    response.sendRedirect("student_dashboard.jsp");
                else if (roleId == 2)
                    response.sendRedirect("staff_dashboard.jsp");
                else
                    response.sendRedirect("admin_dashboard.jsp");
            }

        } else {
            response.sendRedirect("login_otp_verification.jsp?error=invalid");
        }
    }
}