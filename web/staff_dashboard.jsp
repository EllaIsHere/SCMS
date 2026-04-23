<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer roleId = (Integer) session.getAttribute("role_id");
if(roleId == null || roleId != 2){
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TIP SC – Complaint Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet" />
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --black: #000;
      --white: #fff;
      --topbar: #e5e5e5;
      --active-tab: #555;
      --header-row: #e4e4e4;
      --row-a: #ffffff;
      --row-b: #e4e4e4;
      --filter-sel: #dddddd;
      --field-bg: #ededed;
      --key-bg: #eaeaea;
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

    /* ── Tracker ── */
    .tracker { display: flex; gap: 29px; padding: 10px 20px; }
    .stat-card { flex: 1; border: 1px solid var(--black); padding: 6px 8px; }
    .stat-num { font-size: 35px; font-weight: 600; letter-spacing: -0.35px; line-height: 1.5; }
    .stat-label { font-size: 15px; font-weight: 300; letter-spacing: -0.15px; line-height: 1.5; }

    /* ── Filter + Table layout ── */
    .filter-table-layout { display: flex; align-items: flex-start; }

    /* ── Filter Sidebar ── */
    .filter-sidebar {
      width: 216px;
      flex-shrink: 0;
      padding: 10px 20px;
    }
    .filter-section-title {
      font-size: 20px;
      font-weight: 300;
      letter-spacing: -0.2px;
      padding: 10px 0;
    }
    .filter-list { display: flex; flex-direction: column; gap: 8px; }
    .filter-item {
      font-size: 15px;
      font-weight: 300;
      letter-spacing: -0.15px;
      padding: 5px;
      cursor: pointer;
      display: block;
      width: 100%;
      text-align: left;
      background: transparent;
      border: none;
      font-family: 'Inter', sans-serif;
    }
    .filter-item.active { background: var(--filter-sel); border: 1px solid var(--black); }
    .filter-item:hover:not(.active) { background: #f0f0f0; }
    .filter-divider { height: 2px; background: var(--black); margin: 10px 0; }

    /* ── Table Area ── */
    .table-area {
      flex: 1;
      padding: 10px 20px 10px 0;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .search-sort-row { display: flex; align-items: center; gap: 47px; }
    .search-box {
      width: 364px;
      height: 40px;
      border: 1px solid var(--black);
      padding: 5px 20px;
      font-family: 'Inter', sans-serif;
      font-size: 20px;
      font-weight: 300;
      outline: none;
    }
    .search-box:focus { outline: 1px solid var(--black); }
    .sort-select {
      height: 40px;
      background: #dedede;
      border: 1px solid var(--black);
      padding: 5px 20px;
      font-family: 'Inter', sans-serif;
      font-size: 20px;
      font-weight: 300;
      letter-spacing: -0.2px;
      cursor: pointer;
      outline: none;
      appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23000' stroke-width='1.5' fill='none'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 15px center;
      padding-right: 40px;
    }

    /* ── Complaints Table ── */
    .complaints-table { width: 100%; border-collapse: collapse; }
    .complaints-table th {
      background: var(--header-row);
      border: 1px solid var(--black);
      font-size: 18px;
      font-weight: 300;
      letter-spacing: -0.25px;
      padding: 0 10px;
      height: 76px;
      text-align: left;
      vertical-align: middle;
    }
    .complaints-table th.col-sm { width: 45px; }
    .complaints-table th.col-dept { width: 90px; }
    .complaints-table th.col-view { width: 81px; }
    .complaints-table tr:nth-child(odd) td { background: var(--row-a); }
    .complaints-table tr:nth-child(even) td { background: var(--row-b); }
    .complaints-table td { border: 1px solid var(--black); height: 76px; padding: 0 10px; }

    /* ── Divider ── */
    .divider { height: 2px; background: var(--black); margin: 8px 20px 0; }

    /* ── Update Section Header ── */
    .section-header { padding: 8px 20px 0; }
    .section-header-labels { display: flex; gap: 20px; align-items: center; height: 38px; }
    .section-header-labels span { flex: 1; min-width: 0; font-size: 25px; font-weight: 600; letter-spacing: -0.25px; }
    .section-header-lines { display: flex; gap: 20px; margin-top: 4px; }
    .section-header-lines div { flex: 1; min-width: 0; height: 2px; background: var(--black); }

    /* ── Update Panel ── */
    .update-panel {
      display: flex;
      gap: 20px;
      padding: 10px 20px 30px;
      width: 100%;
      overflow: hidden;
    }
    .update-form {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: 20px;
      overflow: hidden;
    }
    .update-right {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: 10px;
      overflow: hidden;
    }

    /* form fields */
    .form-group { display: flex; flex-direction: column; gap: 10px; }
    .form-label { font-size: 18px; font-weight: 500; color: var(--black); text-transform: uppercase; letter-spacing: -0.2px; line-height: 1.5; }
    .form-select,
    .form-input,
    .form-textarea {
      font-family: 'Inter', sans-serif;
      font-size: 18px;
      font-weight: 400;
      background: var(--field-bg);
      border: 1px solid var(--black);
      padding: 5px 10px;
      width: 100%;
      outline: none;
    }
    .form-select { height: 40px; cursor: pointer; appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23000' stroke-width='1.5' fill='none'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 10px center; background-color: var(--field-bg); padding-right: 30px; }
    .form-input { height: 40px; }
    .form-textarea { resize: none; }
    .form-select:focus, .form-input:focus, .form-textarea:focus { outline: 1px solid var(--black); }

    .save-btn-row { display: flex; justify-content: flex-end; }
    .save-btn {
      background: var(--black);
      color: var(--white);
      border: none;
      font-family: 'Inter', sans-serif;
      font-size: 20px;
      font-weight: 600;
      padding: 2px 20px;
      cursor: pointer;
    }
    .save-btn:hover { background: #333; }

    /* activity log */
    .activity-entry { display: flex; align-items: flex-start; padding: 4px 0; }
    .activity-avatar { width: 49px; height: 49px; flex-shrink: 0; }
    .activity-avatar img { width: 100%; height: 100%; }
    .activity-text { padding-left: 10px; }
    .activity-meta { font-size: 15px; font-weight: 300; letter-spacing: -0.15px; line-height: 1.5; }
    .activity-info { font-size: 22px; font-weight: 500; letter-spacing: -0.25px; line-height: 1.5; }
    .activity-divider { height: 2px; background: var(--black); margin: 4px 0; }

    /* student info */
    .student-info-label {
      font-size: 20px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: -0.2px;
      margin-top: 10px;
    }
    .student-info-line { height: 2px; background: var(--black); margin: 4px 0 0; }
    .student-table { width: 100%; border-collapse: collapse; margin-top: 0; }
    .student-table td { border: 1px solid var(--black); height: 51px; padding: 0 5px; font-size: 18px; vertical-align: middle; }
    .student-table td.key { background: var(--key-bg); font-weight: 500; text-transform: uppercase; width: 251px; letter-spacing: -0.25px; }
    .student-table td.val { font-weight: 400; }
  </style>
</head>
<body>

<!-- Top Bar -->
<header class="topbar">
    <div class="topbar-left">
        <div class="logo">
            <img src="https://www.figma.com/api/mcp/asset/9e8594fc-775f-4dc2-ba28-dddc27a6f1ca" alt="logo" />
            <span class="logo-brand">TIP SC</span>
        </div>
        <div class="nav-tab active">Student Complaints</div>
    </div>
    <div class="topbar-account">
        <img src="https://www.figma.com/api/mcp/asset/a6394b55-0b61-4b92-81c7-956a7389ef11" alt="account" />
        <span><%= session.getAttribute("fullName") %></span>
    </div>
</header>

<!-- Page Header -->
<div class="page-header">
    <h1 class="page-title">Complaint Management</h1>
    <p class="page-subtitle">Review, assign, update status, and respond to student complaints.</p>
</div>

<!-- Tracker -->
<div class="tracker">
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">TOTAL SUBMITTED</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">PENDING</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">OPEN</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">IN REVIEW</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">CLOSED</div></div>
</div>

<!-- Filter + Table -->
<div class="filter-table-layout">

    <!-- Filter Sidebar -->
    <aside class="filter-sidebar">
        <p class="filter-section-title">Filter by Status</p>
        <div class="filter-list">
            <button class="filter-item active">All Complaints</button>
            <button class="filter-item">Pending</button>
            <button class="filter-item">Open</button>
            <button class="filter-item">In Review</button>
            <button class="filter-item">Closed</button>
        </div>
        <div class="filter-divider"></div>
        <p class="filter-section-title">Filter by Dept.</p>
        <div class="filter-list">
            <button class="filter-item active">All Department</button>
            <button class="filter-item">Dept. 1</button>
            <button class="filter-item">Dept. 2</button>
            <button class="filter-item">Dept. 3</button>
            <button class="filter-item">Dept. 4</button>
        </div>
    </aside>

    <!-- Table Area -->
    <div class="table-area">
        <div class="search-sort-row">
            <input class="search-box" type="text" placeholder="Search complaints..." />
            <select class="sort-select">
                <option>Sort: Newest first</option>
                <option>Sort: Oldest first</option>
                <option>Sort: Status</option>
            </select>
        </div>

        <table class="complaints-table">
            <thead>
                <tr>
                    <th class="col-sm">ID</th>
                    <th>STUDENT</th>
                    <th>TITLE</th>
                    <th>CATEGORY</th>
                    <th class="col-dept">DEPT.</th>
                    <th>SUBMITTED</th>
                    <th>STATUS</th>
                    <th>ASSIGNED TO</th>
                    <th class="col-view">VIEW</th>
                </tr>
                </thead>
            <tbody>
            <%
            List<Map<String,Object>> complaints =
                (List<Map<String,Object>>) request.getAttribute("complaints");

            if(complaints != null){
                for(Map<String,Object> c : complaints){
            %>
            <tr>
                <td><%= c.get("ID") %></td>
                <td><%= c.get("STUDENT_NAME") %></td>
                <td><%= c.get("TITLE") %></td>
                <td><%= c.get("CATEGORY") %></td>
                <td><%= c.get("DEPARTMENT") %></td>
                <td><%= c.get("SUBMITTED_AT") %></td>
                <td><%= c.get("STATUS") %></td>
                <td><%= c.get("ASSIGNED_TO") %></td>
                <td>
                    <a href="ViewComplaintServlet?id=<%= c.get("ID") %>">
                        View
                    </a>
                </td>
            </tr>
            <%
                }
            }
            %>
            </tbody>
        </table>
    </div>
</div>

<!-- Divider -->
<div class="divider"></div>

<!-- Update Section Header -->
<div class="section-header">
    <div class="section-header-labels">
        <span>Update Complaint</span>
        <span>Activity Log</span>
    </div>
    <div class="section-header-lines"><div></div><div></div></div>
</div>

<!-- Update Panel -->
<div class="update-panel">

    <!-- Left: update form -->
    <form action="UpdateComplaintServlet" method="post" class="update-form">

        <div class="form-group">
            <label class="form-label" for="status">Update Status To</label>
            <select class="form-select" id="status" name="status">
                <option>Pending</option>
                <option selected>In Review</option>
                <option>Open</option>
                <option>Closed</option>
            </select>
        </div>

        <div class="form-group">
            <label class="form-label" for="assign">Assign To</label>
            <input class="form-input" id="assign" name="assignedTo" type="text" placeholder="Dept. Staff Name" />
        </div>

        <div class="form-group">
            <label class="form-label" for="notes">Decision / Resolution Notes <span style="text-transform:none;font-weight:400;">(internal, not shown to student)</span></label>
            <textarea class="form-textarea" id="notes" name="internalNotes" style="height:117px;" placeholder="Internal notes for record-keeping..."></textarea>
        </div>

        <div class="form-group">
            <label class="form-label" for="response">Response to Student</label>
            <textarea class="form-textarea" id="response" name="responseMessage" style="height:117px;" placeholder="This message will be visible to the student in their complaint thread..."></textarea>
        </div>

        <div class="save-btn-row">
            <button class="save-btn">Save &amp; Notify Student &nbsp;→</button>
        </div>

    </div>

    <input type="hidden" name="complaintId" value="<%= request.getParameter("id") %>">

    <!-- Right: activity log + student info -->
    <div class="update-right">

        <div class="activity-entry">
            <div class="activity-avatar"><img src="https://www.figma.com/api/mcp/asset/5f8ac1c5-2a24-4651-915c-89ff64c6eea8" alt="user" /></div>
            <div class="activity-text">
                <p class="activity-meta">Full Name - Date - Time</p>
                <p class="activity-info">Info</p>
            </div>
        </div>

        <div class="activity-divider"></div>

        <div class="activity-entry">
            <div class="activity-avatar"><img src="https://www.figma.com/api/mcp/asset/5f8ac1c5-2a24-4651-915c-89ff64c6eea8" alt="user" /></div>
            <div class="activity-text">
                <p class="activity-meta">Full Name - Date - Time</p>
                <p class="activity-info">Info</p>
            </div>
        </div>

        <div class="activity-divider"></div>

        <div class="activity-entry">
            <div class="activity-avatar"><img src="https://www.figma.com/api/mcp/asset/5f8ac1c5-2a24-4651-915c-89ff64c6eea8" alt="user" /></div>
            <div class="activity-text">
                <p class="activity-meta">Full Name - Date - Time</p>
                <p class="activity-info">Info</p>
            </div>
        </div>

        <p class="student-info-label">Student Info</p>
        <div class="student-info-line"></div>

        <table class="student-table">
            <tr><td class="key">Name</td><td class="val">Full Name</td></tr>
            <tr><td class="key">Student ID</td><td class="val">#</td></tr>
            <tr><td class="key">Program</td><td class="val">Prog - Year</td></tr>
            <tr><td class="key">Email</td><td class="val">name@tip.edu.ph</td></tr>
            <tr><td class="key">Complaints (Total)</td><td class="val">#</td></tr>
        </table>

    </form>
</div>

</body>
</html>