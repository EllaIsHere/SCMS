    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer roleId = (Integer) session.getAttribute("role_id");
if(roleId == null || roleId != 1){
    response.sendRedirect("submit_complaint.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TIP SC – Submit a Complaint</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet" />
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --black: #000;
      --white: #fff;
      --topbar: #e5e5e5;
      --active-tab: #555;
      --field-bg: #ffffff;
      --sidebar-bg: #ededed;
      --optional-gray: #696969;
      --time-label: #505050;
    }

    body { font-family: 'Inter', sans-serif; background: var(--white); min-width: 1440px; }

    /* ── Topbar ── */
    .topbar {
      background: var(--topbar);
      height: 80px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 21px;
    }
    .topbar-left { display: flex; align-items: center; height: 100%; }
    .logo { display: flex; align-items: center; }
    .logo img { width: 48px; height: 48px; }
    .logo-brand { font-size: 32px; font-weight: 600; color: var(--black); letter-spacing: -0.32px; }
    .nav-tab {
      height: 100%;
      display: flex;
      align-items: center;
      padding: 0 11px;
      font-size: 25px;
      font-weight: 600;
      color: var(--black);
      cursor: pointer;
      letter-spacing: -0.25px;
    }
    .nav-tab.active { background: var(--active-tab); color: var(--white); }
    .topbar-account { display: flex; align-items: center; gap: 8px; }
    .topbar-account img { width: 48px; height: 48px; }
    .topbar-account span { font-size: 32px; font-weight: 600; letter-spacing: -0.32px; }

    /* ── Page Header ── */
    .page-header { padding: 10px 20px 6px; }
    .page-title { font-size: 25px; font-weight: 600; letter-spacing: -0.25px; line-height: 1.5; }
    .page-subtitle { font-size: 18px; font-weight: 300; letter-spacing: -0.18px; line-height: 1.5; }

    /* ── Body layout ── */
    .body-layout {
      display: flex;
      gap: 20px;
      padding: 10px 20px;
      align-items: flex-start;
    }

    /* ── Form ── */
    .form { flex: 1; display: flex; flex-direction: column; gap: 20px; }

    .field-group { display: flex; flex-direction: column; gap: 10px; }

    .field-label {
      font-size: 18px;
      font-weight: 400;
      color: var(--black);
      text-transform: uppercase;
      line-height: normal;
    }
    .field-label .optional { color: var(--optional-gray); text-transform: none; font-size: 18px; }

    .field-input,
    .field-select,
    .field-textarea {
      font-family: 'Inter', sans-serif;
      font-size: 18px;
      font-weight: 400;
      color: var(--black);
      background: var(--field-bg);
      border: 1px solid var(--black);
      padding: 10px 15px;
      width: 100%;
      outline: none;
      appearance: none;
      -webkit-appearance: none;
    }
    .field-input { height: 42px; }
    .field-select { height: 42px; cursor: pointer; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23000' stroke-width='1.5' fill='none'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 15px center; }
    .field-input:focus,
    .field-select:focus,
    .field-textarea:focus { outline: 1px solid var(--black); }
    .field-textarea { resize: none; }

    /* drop zone */
    .drop-zone {
      border: 1px dashed var(--black);
      height: 116px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 3px;
      cursor: pointer;
      padding: 10px 15px;
    }
    .drop-zone:hover { background: #fafafa; }
    .drop-main { font-size: 18px; font-weight: 400; }
    .drop-hint { font-size: 10px; font-weight: 400; color: var(--black); }

    /* ── Sidebar ── */
    .sidebar { width: 307px; flex-shrink: 0; display: flex; flex-direction: column; gap: 15px; }

    .sidebar-card {
      background: var(--sidebar-bg);
      border: 1px solid var(--black);
      padding: 20px 15px;
    }
    .sidebar-card-title {
      font-size: 23px;
      font-weight: 500;
      color: var(--black);
      margin-bottom: 10px;
    }

    /* guidelines list */
    .guidelines-list { list-style: disc; padding-left: 20px; display: flex; flex-direction: column; gap: 4px; }
    .guidelines-list li { font-size: 18px; font-weight: 400; line-height: 1.81; }

    /* processing time */
    .time-row {
      display: flex;
      align-items: center;
      height: 36px;
    }
    .time-phase { font-size: 16px; font-weight: 400; color: var(--time-label); width: 122px; }
    .time-spacer { flex: 1; }
    .time-days { font-size: 20px; font-weight: 500; color: var(--black); }

    /* ── Footer bar ── */
    .footer-bar {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      padding: 10px 20px 30px;
    }
    .btn-draft {
      background: var(--white);
      border: 1px solid var(--black);
      font-family: 'Inter', sans-serif;
      font-size: 18px;
      font-weight: 400;
      padding: 7px 20px;
      cursor: pointer;
    }
    .btn-draft:hover { background: #f0f0f0; }
    .btn-submit {
      background: var(--black);
      color: var(--white);
      border: none;
      font-family: 'Inter', sans-serif;
      font-size: 18px;
      font-weight: 400;
      padding: 7px 20px;
      cursor: pointer;
    }
    .btn-submit:hover { background: #333; }
  </style>
</head>
<body>

    <!-- Top Bar -->
    <header class="topbar">
        <div class="topbar-left">
            <div class="logo">
                <img src="https://www.figma.com/api/mcp/asset/1b10c86a-e53c-4491-9589-14dd976c5fc7" alt="logo" />
                <span class="logo-brand">TIP SC</span>
            </div>
            <div class="nav-tab">My Complaints</div>
            <div class="nav-tab active">Submit Complaint</div>
        </div>
        <div class="topbar-account">
            <img src="https://www.figma.com/api/mcp/asset/8d7bba3e-1c99-46bd-9e4f-af52b13fc269" alt="account" />
            <span><%= session.getAttribute("fullName") %></span>
        </div>
    </header>

    <!-- Page Header -->
    <div class="page-header">
        <h1 class="page-title">Submit a Complaint</h1>
        <p class="page-subtitle">Fill in the form below. You will receive updates via your student email.</p>
    </div>

    <!-- Body -->
    <div class="body-layout">

    <!-- Form -->
    <form action="SubmitComplaintServlet" method="post" enctype="multipart/form-data" class="form">

        <div class="field-group">
            <label class="field-label" for="category">Category</label>
            <select class="field-select" id="category" name="category" required>
                <option value="" disabled selected>-- Select Category --</option>
                <option>Academic</option>
                <option>Administrative</option>
                <option>Facilities</option>
                <option>Other</option>
            </select>
        </div>

        <div class="field-group">
            <label class="field-label" for="subject">Subject / Title</label>
            <input class="field-input" id="subject" name="subject" type="text" placeholder="Brief description of the complaint (max 120 chars)" maxlength="120" required />
        </div>

        <div class="field-group">
            <label class="field-label" for="department">Department Involved</label>
            <select class="field-select" id="department" name="department" required>
                <option value="" disabled selected>-- Select Department --</option>
                <option>Dept. 1</option>
                <option>Dept. 2</option>
                <option>Dept. 3</option>
                <option>Dept. 4</option>
            </select>
        </div>

        <div class="field-group">
            <label class="field-label" for="details">Complaint Details</label>
            <textarea class="field-textarea" id="details" name="details" style="height:153px;" placeholder="Describe your complaint in detail. Include relevant dates, names, and any supporting information..." required></textarea>
        </div>

        <div class="field-group">
            <label class="field-label" for="resolution">Preferred Resolution</label>
            <textarea class="field-textarea" id="resolution" name="resolution" style="height:116px;" placeholder="Describe what outcome you are hoping for..."></textarea>
        </div>

        <div class="field-group">
            <p class="field-label">Supporting Attachments <span class="optional">(optional)</span></p>
            <div class="drop-zone">
                <p class="drop-main">[ Drop files here or click to upload ]</p>
                <p class="drop-hint">PDF, JPG, PNG – max 10 MB each</p>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="footer-bar">
            <button type="button" class="btn-draft">Save Draft</button>
            <button type="submit" class="btn-submit">Submit Complaint &nbsp;→</button>
        </div>
        
    </form>

    <!-- Sidebar -->
        <aside class="sidebar">

            <div class="sidebar-card">
                <p class="sidebar-card-title">Complaint Guidelines</p>
                <ul class="guidelines-list">
                    <li>Be specific and factual</li>
                    <li>Avoid offensive language</li>
                    <li>One issue per submission</li>
                    <li>Review policy before submitting</li>
                </ul>
            </div>

            <div class="sidebar-card">
                <p class="sidebar-card-title">Processing Time</p>
                <div class="time-row"><span class="time-phase">Initial review</span><span class="time-spacer"></span><span class="time-days">3 days</span></div>
                <div class="time-row"><span class="time-phase">Response</span><span class="time-spacer"></span><span class="time-days">7 days</span></div>
                <div class="time-row"><span class="time-phase">Resolution</span><span class="time-spacer"></span><span class="time-days">21 days</span></div>
            </div>

        </aside>
    </div>

</body>
</html>