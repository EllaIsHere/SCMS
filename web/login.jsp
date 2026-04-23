<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | SCMS v1.0</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">

<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>


</head>

<body>

<!-- SIGN IN SCREEN -->
<div class="screen active">
  <div class="card">
    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <h1 class="title">SIGN IN</h1>
    <p class="sub">Sign in with your Institutional credentials.</p>

    <% 
        String error = request.getParameter("error");
        if(error != null){
    %>
        <div class="warn">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <span>Invalid email or password.</span>
        </div>
    <% } %>

    <!-- REAL FORM STARTS HERE -->
    <form action="LoginServlet" method="post">

        <div class="f">
            <label class="lbl">SCHOOL EMAIL: <span class="req">*</span></label>
            <div class="iw">
                <i class="fa-solid fa-envelope ico"></i>
                <input type="email" name="email" required/>
            </div>
        </div>

        <div class="f">
            <label class="lbl">PASSWORD: <span class="req">*</span></label>
            <div class="iw">
                <i class="fa-solid fa-lock ico"></i>
                <input type="password" name="password" required/>
            </div>
        </div>

        <button type="submit" class="btn btn-y">SIGN IN</button>

    </form>

    <div class="links">
        <a href="register.jsp">Haven't registered yet?</a>
        <a href="forgot_password.jsp">Forgot Password?</a>
    </div>

    <div class="foot">@2026 TIP-MANILA SCMS v1.0</div>
  </div>
</div>

</body>
</html>