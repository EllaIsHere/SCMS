package util;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.sql.*;
import java.util.Properties;

public class DBConnection {
    public static Connection getConnection() throws SQLException {
        String host = "localhost";
        int port = 1521;
        String url = "jdbc:oracle:thin:@" + host + ":" + port + ":xe";
        String user = "SYSTEM";
        String pass = "phainon";

        // Socket-level check — fails within 5 seconds if DB is unreachable
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(host, port), 5000);
        } catch (IOException e) {
            throw new SQLException("Database server is not reachable: " + e.getMessage());
        }

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Oracle JDBC driver not found: " + e.getMessage());
        }

        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pass);
        props.setProperty("oracle.net.CONNECT_TIMEOUT", "5000");
        props.setProperty("oracle.jdbc.loginTimeout", "5");

        return DriverManager.getConnection(url, props);
    }
}