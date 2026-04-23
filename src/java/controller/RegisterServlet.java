package controller;

import util.DBConnection;
import util.EmailUtil;
import java.io.IOException;
import java.sql.*;
import java.util.Random;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String roleParam = request.getParameter("role");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String schoolId = request.getParameter("school_id");
        String campus = request.getParameter("campus");
        String program = request.getParameter("program");
        String department = request.getParameter("department");
        
        System.out.println("=== RegisterServlet Started ===");
        System.out.println("Role: " + roleParam);
        System.out.println("Email: " + email);
        System.out.println("First Name: " + firstName);
        System.out.println("Last Name: " + lastName);
        System.out.println("School ID: " + schoolId);
        System.out.println("Campus: " + campus);
        System.out.println("Program: " + program);
        System.out.println("Department: " + department);
        
        if(email == null || password == null || firstName == null || lastName == null || schoolId == null) {
            System.out.println("ERROR: Missing required fields");
            response.sendRedirect("register.jsp?error=missing");
            return;
        }
        
        // Determine role_id
        int roleId = 1; // default student
        if(roleParam != null) {
            if(roleParam.equalsIgnoreCase("manager")) roleId = 2;
            else if(roleParam.equalsIgnoreCase("admin")) roleId = 3;
        }
        
        System.out.println("Role ID: " + roleId);
        
        String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
        System.out.println("Password hashed successfully");

        try(Connection conn = DBConnection.getConnection()){

            // Check if email already exists
            System.out.println("Checking if email already registered...");
            String checkSql = "SELECT user_id FROM users WHERE email=?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, email);
            ResultSet checkRs = checkPs.executeQuery();

            if(checkRs.next()){
                System.out.println("ERROR: Email already registered");
                response.sendRedirect("register.jsp?error=email_exists");
                return;
            }
            
            System.out.println("Email is available, proceeding with registration");
            
            // Generate OTP for email verification
            String otp = String.valueOf(100000 + new Random().nextInt(900000));
            System.out.println("Generated OTP: " + otp);

            // Store registration data in session (NOT in database yet!)
            HttpSession session = request.getSession();
            session.setAttribute("tempEmail", email);
            session.setAttribute("tempPassword", hashed);
            session.setAttribute("tempFirstName", firstName);
            session.setAttribute("tempLastName", lastName);
            session.setAttribute("tempSchoolId", schoolId);
            session.setAttribute("tempCampus", campus);
            session.setAttribute("tempProgram", program);
            session.setAttribute("tempDepartment", department);
            session.setAttribute("tempRoleId", roleId);
            session.setAttribute("otp", otp);
            session.setAttribute("otpEmail", email);
            session.setAttribute("otpExpiry", System.currentTimeMillis() + (10 * 60 * 1000)); // 10 minutes
            session.setAttribute("otpVerified", false);

            // Send OTP email
            System.out.println("Sending OTP to: " + email);
            boolean emailSent = EmailUtil.sendOTPEmailHTML(email, otp);
            System.out.println("Email sent status: " + emailSent);
            
            if(!emailSent) {
                System.out.println("WARNING: Email failed to send. Check your email configuration.");
            }

            System.out.println("Redirecting to otp_verification.jsp");
            response.sendRedirect("otp_verification.jsp");

        } catch(SQLException e){
            System.out.println("SQL Exception: " + e.getMessage());
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=database");
        } catch(Exception e){
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=system");
        }
        
        System.out.println("=== RegisterServlet Ended ===");
    }
}