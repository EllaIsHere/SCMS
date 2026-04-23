<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer roleId = (Integer) session.getAttribute("role_id");
if(roleId == null || roleId != 1){
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TIP SC – My Complaints</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet" />
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --black: #000;
      --white: #fff;
      --topbar: #e5e5e5;
      --active-tab: #555;
      --header-row: #e4e4e4;
      --row-a: #f5f5f5;
      --row-b: #e6dede;
      --detail-key: #e5e5e5;
      --reply-bg: #ebebeb;
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
    .topbar-left { display: flex; align-items: center; gap: 0; height: 100%; }
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
    .nav-tab:hover { background: #ddd; }
    .topbar-account { display: flex; align-items: center; gap: 8px; }
    .topbar-account img { width: 48px; height: 48px; }
    .topbar-account span { font-size: 32px; font-weight: 600; letter-spacing: -0.32px; }

    /* ── Page Header ── */
    .page-header { padding: 10px 20px 6px; }
    .page-header-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 4px; }
    .page-title { font-size: 25px; font-weight: 600; letter-spacing: -0.25px; }
    .header-buttons { display: flex; gap: 10px; }
    .new-btn {
      background: var(--black); color: var(--white);
      font-family: 'Inter', sans-serif; font-size: 18px; font-weight: 500;
      padding: 3px 8px; border: none; border-radius: 5px; cursor: pointer;
    }
    .new-btn:hover { background: #333; }
    .page-subtitle { font-size: 18px; font-weight: 300; letter-spacing: -0.18px; }

    /* ── Tracker ── */
    .tracker { display: flex; gap: 29px; padding: 10px 20px; }
    .stat-card {
      flex: 1;
      border: 1px solid var(--black);
      padding: 6px 8px;
    }
    .stat-num { font-size: 35px; font-weight: 600; letter-spacing: -0.35px; line-height: 1.5; }
    .stat-label { font-size: 15px; font-weight: 300; letter-spacing: -0.15px; line-height: 1.5; }

    /* ── Filter Row ── */
    .filter-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 4px 20px;
    }
    .filter-left { display: flex; align-items: center; gap: 10px; }
    .filter-label { font-size: 20px; font-weight: 300; letter-spacing: -0.2px; }
    .filter-chip {
      border: 1px solid var(--black);
      padding: 5px;
      font-family: 'Inter', sans-serif;
      font-size: 15px; font-weight: 300;
      letter-spacing: -0.15px;
      cursor: pointer; background: transparent;
    }
    .filter-chip.active { background: var(--black); color: var(--white); }
    .filter-chip:hover:not(.active) { background: #f0f0f0; }
    .search-box {
      width: 296px;
      border: 1px solid var(--black);
      padding: 3px 10px;
      font-family: 'Inter', sans-serif;
      font-size: 20px; font-weight: 300;
      letter-spacing: -0.2px;
      outline: none;
    }
    .search-box:focus { outline: 1px solid var(--black); }

    /* ── Table ── */
    .table-wrap { padding: 0 20px; }
    .table { width: 100%; border-collapse: collapse; }
    .table th {
      background: var(--header-row);
      border: 1px solid var(--black);
      font-size: 18px; font-weight: 300;
      letter-spacing: -0.25px;
      padding: 0 10px;
      height: 38px;
      text-align: left;
    }
    .table th.col-fixed-sm { width: 45px; }
    .table th.col-fixed-lg { width: 81px; }
    .table tr:nth-child(odd) td { background: var(--row-a); }
    .table tr:nth-child(even) td { background: var(--row-b); }
    .table td { border: 1px solid var(--black); height: 38px; padding: 0 10px; font-size: 15px; }

    /* ── Divider ── */
    .divider { height: 2px; background: var(--black); margin: 8px 20px 0; }

    /* ── Detail Section Header ── */
    .detail-header { padding: 8px 20px 0; }
    .detail-header-labels {
      display: flex;
      gap: 20px;
      height: 38px;
      align-items: center;
    }
    .detail-header-labels span {
      flex: 1;
      min-width: 0;
      font-size: 25px;
      font-weight: 600;
      letter-spacing: -0.25px;
    }
    .detail-header-lines {
      display: flex;
      gap: 20px;
      margin-top: 4px;
    }
    .detail-header-lines div { flex: 1; min-width: 0; height: 2px; background: var(--black); }

    /* ── Detail Panel ── */
    .detail-panel {
      display: flex;
      gap: 20px;
      padding: 10px 20px 30px;
      width: 100%;
      overflow: hidden;
    }
    .detail-left {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: 15px;
      overflow: hidden;
    }
    .detail-right {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: 20px;
      overflow: hidden;
    }

    /* detail table */
    .detail-table { width: 100%; border-collapse: collapse; }
    .detail-table td { border: 1px solid var(--black); height: 51px; padding: 0 5px; font-size: 20px; vertical-align: middle; }
    .detail-table td.key { background: var(--detail-key); font-weight: 500; text-transform: uppercase; width: 251px; letter-spacing: -0.25px; }
    .detail-table td.val { font-weight: 400; letter-spacing: -0.25px; }

    /* submission section */
    .submission-label { font-size: 25px; font-weight: 600; letter-spacing: -0.25px; margin-bottom: 4px; }
    .submission-line { height: 2px; background: var(--black); }
    .description-box {
      border: 1px solid var(--black);
      height: 186px;
      padding: 10px;
      font-family: 'Inter', sans-serif;
      font-size: 18px; font-weight: 400;
      width: 100%;
      resize: none;
      outline: none;
      margin-top: 10px;
    }
    .description-box:focus { outline: 1px solid var(--black); }

    /* activity feed */
    .activity-entry { display: flex; align-items: flex-start; gap: 0; }
    .activity-avatar { width: 49px; height: 49px; flex-shrink: 0; }
    .activity-avatar img { width: 100%; height: 100%; }
    .activity-text { padding: 0 0 0 10px; }
    .activity-meta { font-size: 15px; font-weight: 300; letter-spacing: -0.15px; line-height: 1.5; }
    .activity-info { font-size: 22px; font-weight: 500; letter-spacing: -0.25px; line-height: 1.5; }
    .activity-divider { height: 2px; background: var(--black); margin: 6px 0; }

    /* reply box */
    .reply-box {
      border: 1px dashed var(--black);
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .reply-label { font-size: 20px; font-weight: 400; text-transform: uppercase; letter-spacing: -0.2px; }
    .reply-textarea {
      background: var(--reply-bg);
      border: 1px solid var(--black);
      padding: 3px;
      font-family: 'Inter', sans-serif;
      font-size: 18px; font-weight: 400;
      height: 112px;
      resize: none;
      width: 100%;
      outline: none;
    }
    .reply-textarea:focus { outline: 1px solid var(--black); }
    .reply-footer { display: flex; justify-content: flex-end; }
    .reply-btn {
      background: var(--black); color: var(--white);
      font-family: 'Inter', sans-serif; font-size: 18px; font-weight: 500;
      padding: 5px 10px; border: none; cursor: pointer;
    }
    .reply-btn:hover { background: #333; }
  </style>
</head>
<body>

<!-- Top Bar -->
<header class="topbar">
    <div class="topbar-left">
        <div class="logo">
            <img src="https://www.figma.com/api/mcp/asset/bb6eba5f-daae-4d2c-b20a-3e7943a0549d" alt="logo" />
            <span class="logo-brand">TIP SC</span>
        </div>
        <div class="nav-tab active">My Complaints</div>
        <div class="nav-tab" onclick="window.location.href='submit_complaint.jsp'">Submit Complaint</div>
        <div class="nav-tab" onclick="window.location.href='messages.jsp'">Message</div>
    </div>
    <div class="topbar-account">
        <img src="https://www.figma.com/api/mcp/asset/92d22bc0-450b-4022-8844-485488d13931" alt="account" />
        <span><%= session.getAttribute("fullName") %></span>
    </div>
</header>

<!-- Page Header -->
<div class="page-header">
    <div class="page-header-row">
        <h1 class="page-title">My Complaints</h1>
        <a href="submit_complaint.jsp">
            <button type="button" class="new-btn">+ New Complaint</button>
        </a>
    </div>
    <p class="page-subtitle">Track all submissions and view staff responses below.</p>
</div>

<!-- Tracker -->
<div class="tracker">
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">TOTAL SUBMITTED</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">PENDING</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">OPEN</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">IN REVIEW</div></div>
    <div class="stat-card"><div class="stat-num">#</div><div class="stat-label">CLOSED</div></div>
</div>

<!-- Filter Row -->
<div class="filter-row">
    <div class="filter-left">
        <span class="filter-label">FILTER:</span>
        <button class="filter-chip active">All</button>
        <button class="filter-chip">Pending</button>
        <button class="filter-chip">Open</button>
        <button class="filter-chip">In Review</button>
        <button class="filter-chip">Closed</button>
    </div>
    <input class="search-box" type="text" placeholder="Search by title or ID..." />
</div>

<!-- Table -->
<div class="table-wrap">
    <table class="table">
        <thead>
        <tr>
            <th class="col-fixed-sm">ID</th>
            <th>TITLE</th>
            <th>CATEGORY</th>
            <th>DEPARTMENT</th>
            <th>SUBMITTED</th>
            <th>STATUS</th>
            <th>LAST UPDATE</th>
            <th class="col-fixed-lg">VIEW</th>
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
            <td><%= c.get("TITLE") %></td>
            <td><%= c.get("CATEGORY") %></td>
            <td><%= c.get("DEPARTMENT") %></td>
            <td><%= c.get("SUBMITTED_AT") %></td>
            <td><%= c.get("STATUS") %></td>
            <td><%= c.get("UPDATED_AT") %></td>
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

<!-- Divider -->
<div class="divider"></div>

<!-- Detail Section Header -->
<div class="detail-header">
    <div class="detail-header-labels">
        <span>Complaint Details</span>
        <span>Updates &amp; Staff Feedback</span>
    </div>
    <div class="detail-header-lines">
        <div></div>
        <div></div>
    </div>
</div>

<!-- Detail Panel -->
<div class="detail-panel">

    <!-- Left: complaint details -->
    <div class="detail-left">
        <table class="detail-table">
            <tr><td class="key">Complaint ID</td><td class="val">no.#</td></tr>
            <tr><td class="key">Category</td><td class="val">Category</td></tr>
            <tr><td class="key">Department</td><td class="val">Dept.</td></tr>
            <tr><td class="key">Submitted</td><td class="val">Date - Time</td></tr>
            <tr><td class="key">Assigned To</td><td class="val">Dept. Staff Name</td></tr>
            <tr><td class="key">Status</td><td class="val">Status</td></tr>
        </table>

        <div>
            <p class="submission-label">Your Submission</p>
            <div class="submission-line"></div>
        </div>

        <textarea class="description-box" placeholder="Description"></textarea>
    </div>

    <!-- Right: updates & reply -->
    <div class="detail-right">

        <div class="activity-entry">
            <img class="activity-avatar" src="https://www.figma.com/api/mcp/asset/d9821f39-2055-426c-bfa7-8ae96b9c3810" alt="user" />
            <div class="activity-text">
                <p class="activity-meta">Full Name - Date - Time</p>
                <p class="activity-info">Info</p>
            </div>
        </div>
        <div class="activity-divider"></div>

        <div class="activity-entry">
            <img class="activity-avatar" src="https://www.figma.com/api/mcp/asset/d9821f39-2055-426c-bfa7-8ae96b9c3810" alt="user" />
            <div class="activity-text">
                <p class="activity-meta">Full Name - Date - Time</p>
                <p class="activity-info">Info</p>
            </div>
        </div>
        <div class="activity-divider"></div>

        <div class="activity-entry">
            <img class="activity-avatar" src="https://www.figma.com/api/mcp/asset/d9821f39-2055-426c-bfa7-8ae96b9c3810" alt="user" />
            <div class="activity-text">
                <p class="activity-meta">Full Name - Date - Time</p>
                <p class="activity-info">Info</p>
            </div>
        </div>

        <div class="reply-box">
            <p class="reply-label">Add Reply</p>
            <textarea class="reply-textarea" placeholder="Write a follow-up message or provide additional information..."></textarea>
            <div class="reply-footer">
                <button class="reply-btn">Send Reply</button>
            </div>
        </div>

    </div>
</div>

</body>
</html>