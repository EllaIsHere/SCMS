<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Delete Account</title>
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
        }
        h2 {
            color: #d32f2f;
            text-align: center;
        }
        .warning {
            background-color: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        input[type="email"], input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        input[type="email"]:focus, input[type="password"]:focus {
            outline: none;
            border-color: #d32f2f;
            box-shadow: 0 0 5px rgba(211, 47, 47, 0.3);
        }
        .button-group {
            display: flex;
            gap: 10px;
        }
        button {
            flex: 1;
            padding: 10px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .btn-delete {
            background-color: #d32f2f;
            color: white;
        }
        .btn-delete:hover {
            background-color: #b71c1c;
        }
        .btn-cancel {
            background-color: #e0e0e0;
            color: #333;
        }
        .btn-cancel:hover {
            background-color: #bdbdbd;
        }
        .error {
            color: #d32f2f;
            margin-top: 10px;
            padding: 10px;
            background-color: #ffebee;
            border-radius: 4px;
        }
        .info {
            color: #1976d2;
            margin-top: 10px;
            padding: 10px;
            background-color: #e3f2fd;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>⚠️ Delete Account</h2>
        
        <div class="warning">
            <strong>WARNING:</strong> This action is permanent and cannot be undone. 
            All your data will be deleted.
        </div>

        <form action="DeleteAccountServlet" method="POST">
            <div class="form-group">
                <label for="email">Email Address:</label>
                <input type="email" id="email" name="email" required>
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="button-group">
                <button type="button" class="btn-cancel" onclick="window.history.back()">Cancel</button>
                <button type="submit" class="btn-delete" onclick="return confirm('Are you absolutely sure? This cannot be undone.');">Delete Account</button>
            </div>
        </form>

        <% 
            String error = request.getParameter("error");
            if(error != null) {
                String errorMsg = "";
                switch(error) {
                    case "missing": errorMsg = "Email and password are required."; break;
                    case "user_not_found": errorMsg = "User not found."; break;
                    case "invalid_password": errorMsg = "Incorrect password."; break;
                    case "failed": errorMsg = "Failed to delete account. Try again."; break;
                    case "database": errorMsg = "Database error. Please try again later."; break;
                    case "system": errorMsg = "System error. Please try again later."; break;
                    default: errorMsg = "An error occurred.";
                }
                out.println("<div class='error'>❌ Error: " + errorMsg + "</div>");
            }
        %>
    </div>
</body>
</html>