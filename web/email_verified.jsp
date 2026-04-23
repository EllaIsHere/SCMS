<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Email Verified | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

</head>
<body>

<div class="card">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <div style="text-align: center; margin: 30px 0;">
        <i class="fa-solid fa-circle-check" style="font-size: 60px; color: #28a745;"></i>
    </div>

    <h1 class="title md" style="text-align: center;">Email verified!</h1>
    <p class="sub" style="text-align: center;">Your account has been created. You can now request your temporary password to sign in for the first time.</p>

    <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0; text-align: left;">
        <p style="margin: 5px 0;"><strong>Email:</strong> <%= session.getAttribute("otpEmail") %></p>
        <p style="margin: 5px 0;"><strong>School ID:</strong> <%= session.getAttribute("otpSchoolId") %></p>
    </div>

    <form action="SendTemporaryPasswordServlet" method="post">
        <button type="submit" class="btn btn-y" style="width: 100%;">
            GET TEMPORARY PASSWORD
        </button>
    </form>

</div>

</body>
</html>