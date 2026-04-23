package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/VerifyOTPServlet")
public class VerifyOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        System.out.println("=== VerifyOTPServlet Started ===");
        
        String enteredOtp = request.getParameter("otp");
        HttpSession session = request.getSession();

        String realOtp = (String) session.getAttribute("otp");
        Long expiry = (Long) session.getAttribute("otpExpiry");
        String email = (String) session.getAttribute("otpEmail");

        System.out.println("Entered OTP: " + enteredOtp);
        System.out.println("Real OTP: " + realOtp);
        System.out.println("Email: " + email);

        if(realOtp == null || expiry == null){
            System.out.println("ERROR: OTP session attributes missing");
            response.sendRedirect("register.jsp");
            return;
        }

        if(System.currentTimeMillis() > expiry){
            System.out.println("ERROR: OTP expired");
            response.sendRedirect("otp_verification.jsp?error=expired");
            return;
        }

        if(!realOtp.equals(enteredOtp)){
            System.out.println("ERROR: OTP mismatch");
            response.sendRedirect("otp_verification.jsp?error=invalid");
            return;
        }

        // OTP is correct! Now insert user into database
        System.out.println("SUCCESS: OTP verified");
        
        try(Connection conn = DBConnection.getConnection()){
            
            // Retrieve registration data from session
            String firstName = (String) session.getAttribute("tempFirstName");
            String lastName = (String) session.getAttribute("tempLastName");
            String schoolId = (String) session.getAttribute("tempSchoolId");
            String password = (String) session.getAttribute("tempPassword");
            Integer roleId = (Integer) session.getAttribute("tempRoleId");
            String program = (String) session.getAttribute("tempProgram");
            String department = (String) session.getAttribute("tempDepartment");
            
            System.out.println("Retrieved from session:");
            System.out.println("  Email: " + email);
            System.out.println("  First Name: " + firstName);
            System.out.println("  Last Name: " + lastName);
            System.out.println("  School ID: " + schoolId);
            System.out.println("  Role ID: " + roleId);
            
            // Now insert the verified user into database
            System.out.println("Inserting verified user into database...");
            String fullName = firstName + " " + lastName;
            
            String insertSql = "INSERT INTO users (school_id, first_name, last_name, full_name, email, password, role_id, program, is_verified, access_status, force_change, created_at) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Y', 'Active', 'Y', SYSDATE)";
            PreparedStatement insertPs = conn.prepareStatement(insertSql);
            insertPs.setString(1, schoolId);
            insertPs.setString(2, firstName);
            insertPs.setString(3, lastName);
            insertPs.setString(4, fullName);
            insertPs.setString(5, email);
            insertPs.setString(6, password);
            insertPs.setInt(7, roleId != null ? roleId : 1);
            insertPs.setString(8, program != null ? program : department);
            
            System.out.println("Executing INSERT query...");
            int rows = insertPs.executeUpdate();
            
            System.out.println("Rows inserted: " + rows);
            
            if(rows > 0) {
                System.out.println("User successfully registered and verified in database");
                
                // Clear OTP and temporary data from session
                session.removeAttribute("otp");
                session.removeAttribute("otpExpiry");
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpVerified");
                session.removeAttribute("tempEmail");
                session.removeAttribute("tempPassword");
                session.removeAttribute("tempFirstName");
                session.removeAttribute("tempLastName");
                session.removeAttribute("tempSchoolId");
                session.removeAttribute("tempCampus");
                session.removeAttribute("tempProgram");
                session.removeAttribute("tempDepartment");
                session.removeAttribute("tempRoleId");
                
                System.out.println("Redirecting to registration success page");
                response.sendRedirect("registration_success.jsp");
            } else {
                System.out.println("ERROR: Failed to insert user into database");
                response.sendRedirect("otp_verification.jsp?error=failed");
            }
            
        } catch(SQLException e){
            System.out.println("SQL Exception: " + e.getMessage());
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            response.sendRedirect("otp_verification.jsp?error=database");
        } catch(Exception e){
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("otp_verification.jsp?error=system");
        }
        
        System.out.println("=== VerifyOTPServlet Ended ===");
    }
}