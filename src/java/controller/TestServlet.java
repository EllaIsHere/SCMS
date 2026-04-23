package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import util.DBConnection;

@WebServlet("/TestServlet")
public class TestServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            Connection conn = DBConnection.getConnection();

            if (conn != null) {
                out.println("<h2 style='color:green;'>Database Connected Successfully!</h2>");
                conn.close();
            } else {
                out.println("<h2 style='color:red;'>Database Connection Failed.</h2>");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}