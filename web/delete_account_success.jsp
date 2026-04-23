<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Account Deleted</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
        }
        h2 { color: #388e3c; }
        p { color: #555; margin: 15px 0; }
        .btn-home {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 25px;
            background-color: #1976d2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-weight: bold;
        }
        .btn-home:hover { background-color: #1565c0; }
    </style>
</head>
<body>
    <div class="container">
        <h2>✅ Account Deleted</h2>
        <p>Your account has been permanently deleted.</p>
        <p>All associated data has been removed from the system.</p>
        <a href="login.jsp" class="btn-home">Back to Login</a>
    </div>
</body>
</html>