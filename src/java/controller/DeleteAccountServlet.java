package controller;

import util.DBConnection;
import util.MessageUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/DeleteAccountServlet")
public class DeleteAccountServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("=== DeleteAccountServlet Started ===");
        System.out.println("Email to delete: " + email);

        if(email == null || password == null) {
            System.out.println("ERROR: Missing email or password");
            response.sendRedirect("delete_account.jsp?error=missing");
            return;
        }

        try(Connection conn = DBConnection.getConnection()){

            // First, verify user exists and password is correct
            System.out.println("Verifying user credentials...");
            String selectSql = "SELECT user_id, password FROM users WHERE email = ?";
            PreparedStatement selectPs = conn.prepareStatement(selectSql);
            selectPs.setString(1, email);
            ResultSet rs = selectPs.executeQuery();

            if(!rs.next()) {
                System.out.println("ERROR: User not found");
                response.sendRedirect("delete_account.jsp?error=user_not_found");
                return;
            }

            int userId = rs.getInt("user_id");
            String hashedPassword = rs.getString("password");
            
            System.out.println("DEBUG: Email found in database");
            System.out.println("DEBUG: Comparing entered password with hashed password using BCrypt");
            
            // Use BCrypt to verify the password
            if(!BCrypt.checkpw(password, hashedPassword)) {
                System.out.println("ERROR: Password incorrect");
                response.sendRedirect("delete_account.jsp?error=invalid_password");
                return;
            }

            System.out.println("SUCCESS: Password verified!");
            
            // Password verified - delete all associated messages and conversations
            System.out.println("Deleting all messages and conversations for user: " + userId);
            MessageUtil.deleteUserMessages(userId);
            
            // Now delete the user account
            System.out.println("Password verified. Proceeding with account deletion...");
            
            String deleteSql = "DELETE FROM users WHERE email = ?";
            PreparedStatement deletePs = conn.prepareStatement(deleteSql);
            deletePs.setString(1, email);
            int rows = deletePs.executeUpdate();

            System.out.println("Rows deleted: " + rows);

            if(rows > 0) {
                System.out.println("SUCCESS: User account permanently deleted");
                
                // Invalidate session
                HttpSession session = request.getSession();
                session.invalidate();
                
                response.sendRedirect("delete_account_success.jsp");
            } else {
                System.out.println("ERROR: Failed to delete user");
                response.sendRedirect("delete_account.jsp?error=failed");
            }

        } catch(SQLException e){
            System.out.println("SQL Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("delete_account.jsp?error=database");
        } catch(Exception e){
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("delete_account.jsp?error=system");
        }

        System.out.println("=== DeleteAccountServlet Ended ===");
    }
}