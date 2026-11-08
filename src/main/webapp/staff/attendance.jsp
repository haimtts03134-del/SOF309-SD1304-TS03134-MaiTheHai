<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung phía Nhân viên -->
<jsp:include page="common/staff-header.jsp" />

<div class="container py-2">

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${not empty sessionScope.staffSuccessMsg}">
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 14px;">
            <i class="bi bi-check-circle-fill me-2 fs-5 align-middle"></i>
            <strong>Thành công!</strong> ${sessionScope.staffSuccessMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="staffSuccessMsg" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.staffErrorMsg}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 14px;">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5 align-middle"></i>
            <strong>Thất bại!</strong> ${sessionScope.staffErrorMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="staffErrorMsg" scope="session" />
    </c:if>

    <!-- Khối Banner Đồng Hồ Thời Gian Thực & Thẻ Chấm Công -->
    <div class="row g-4 mb-4">
        <!-- Cột trái: Đồng hồ thời gian thực & thông tin nhân viên -->
        <div class="col-12 col-lg-5">
            <div class="card border-0 shadow-sm p-4 h-100 text-white rounded-4" 
                 style="background: linear-gradient(135deg, #1e1b18 0%, #3a322d 100%);">
                <div class="p-3 rounded-3 mb-3 d-flex align-items-center" 
                     style="background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.15);">
                    <c:choose>
                        <c:when test="${not empty staffUser.hinhAnh}">
                            <c:set var="userImgUrl" value="${staffUser.hinhAnh}" />
                            <c:if test="${!staffUser.hinhAnh.startsWith('http') && !staffUser.hinhAnh.startsWith('data:') && !staffUser.hinhAnh.startsWith('/')}">
                                <c:set var="userImgUrl" value="${pageContext.request.contextPath}/admin/images/${staffUser.hinhAnh}" />
                            </c:if>
                            <img src="${userImgUrl}" class="rounded-circle border border-2 border-warning me-3 shadow-sm" 
                                 style="width: 55px; height: 55px; object-fit: cover;" alt="${staffUser.hoTen}"
                                 onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100';">
                        </c:when>
                        <c:otherwise>
                            <div class="rounded-circle border border-2 border-warning me-3 bg-white text-dark d-flex align-items-center justify-content-center shadow-sm" style="width: 55px; height: 55px;">
                                <i class="bi bi-person fs-3"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <div class="overflow-hidden">
                        <small class="d-block text-warning opacity-75" style="font-size: 0.75rem; font-weight: 500;">Tài khoản đang trực:</small>
                        <h5 class="fw-bold mb-0 text-white text-truncate" title="${staffUser.hoTen}">${staffUser.hoTen}</h5>
                        <small style="color: var(--secondary-gold); font-size: 0.82rem;" class="text-truncate d-block">${staffUser.email}</small>
                    </div>
                </div>

                <hr class="border-secondary opacity-25 my-3">

                <!-- Đồng hồ kỹ thuật số -->
                <div class="my-auto text-center py-2">
                    <span class="text-white-50 text-uppercase fw-semibold" style="font-size: 0.8rem; letter-spacing: 1px;">
                        <i class="bi bi-clock me-1 text-warning"></i>Thời gian hiện tại
                    </span>
                    <div id="liveClockTime" class="fw-bold display-5 my-1" style="color: var(--secondary-gold); font-family: monospace;">
                        00:00:00
                    </div>
                    <div id="liveClockDate" class="text-white-50 small">
                        Đang tải thời gian...
                    </div>
                </div>

                <div class="mt-auto pt-3 border-top border-secondary border-opacity-25 d-flex justify-content-between text-white-50 small">
                    <span><i class="bi bi-calendar-event me-1"></i>Hôm nay: <strong class="text-white" id="todayDateStr">--/--/----</strong></span>
                    <span class="badge bg-warning text-dark px-2 py-1">Ca Sáng: 7h - 11h30</span>
                </div>
            </div>
        </div>

        <!-- Cột phải: Khu vực nút Chấm Công Vào Ca / Ra Ca -->
        <div class="col-12 col-lg-7">
            <c:choose>
                <c:when test="${not empty activeShift}">
                    <!-- Trường hợp: ĐANG TRONG CA LÀM VIỆC (Đã Check-in, Chưa Check-out) -->
                    <div class="card border-0 shadow-sm p-4 h-100 rounded-4 border-start border-5 border-success" style="background-color: white;">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="badge bg-success-subtle text-success border border-success rounded-pill px-3 py-2 fs-6">
                                <i class="bi bi-record-circle-fill me-1 animated pulse"></i> Đang Trong Ca Làm Việc
                            </span>
                            <small class="text-muted">Mã ca: #${activeShift.maChamCong}</small>
                        </div>

                        <h4 class="fw-bold text-dark mb-1">${activeShift.tenCa}</h4>
                        <p class="text-muted mb-3" style="font-size: 0.9rem;">
                            Thời gian vào ca: 
                            <strong class="text-success fs-5 ms-1">
                                <fmt:formatDate value="${activeShift.gioVao}" pattern="HH:mm:ss" />
                            </strong>
                            <span class="ms-2 badge ${activeShift.trangThai == 'CoMat' ? 'bg-success' : 'bg-warning text-dark'}">
                                ${activeShift.trangThai == 'CoMat' ? 'Có mặt (Đúng giờ)' : 'Đi muộn'}
                            </span>
                        </p>

                        <c:if test="${not empty activeShift.ghiChu}">
                            <div class="alert alert-light border p-2 mb-4 rounded-3 text-secondary small">
                                <i class="bi bi-info-circle me-1 text-primary"></i>Ghi chú: ${activeShift.ghiChu}
                            </div>
                        </c:if>

                        <div class="mt-auto">
                            <form action="${pageContext.request.contextPath}/staff/attendance" method="post" id="checkoutForm">
                                <input type="hidden" name="action" value="checkout">
                                <input type="hidden" name="maChamCong" value="${activeShift.maChamCong}">
                                <button type="button" class="btn btn-danger btn-lg w-100 py-3 rounded-3 fw-bold shadow" data-bs-toggle="modal" data-bs-target="#confirmCheckoutModal">
                                    <i class="bi bi-box-arrow-right me-2"></i>KẾT THÚC RA CA (CHECK-OUT)
                                </button>
                            </form>
                        </div>
                    </div>
                </c:when>

                <c:when test="${isCurrentShiftCompleted}">
                    <!-- Trường hợp: ĐÃ KẾT THÚC CA LÀM TRONG KHUNG GIỜ HIỆN TẠI -->
                    <div class="card border-0 shadow-sm p-4 h-100 rounded-4 border-start border-5 border-warning" style="background-color: white;">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="badge bg-warning-subtle text-warning border border-warning rounded-pill px-3 py-2 fs-6">
                                <i class="bi bi-check-circle-fill me-1"></i> Ca Làm Việc Đã Hoàn Thành
                            </span>
                            <small class="text-muted">Hệ thống ghi nhận</small>
                        </div>

                        <h4 class="fw-bold text-dark mb-2">${completedShiftName}</h4>
                        <div class="alert alert-info border-0 bg-info bg-opacity-10 text-dark p-3 rounded-3 mb-4">
                            <i class="bi bi-info-circle-fill text-info fs-5 me-2 align-middle"></i>
                            <span>${nextShiftMessage}</span>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <div class="p-2 border rounded text-center bg-light">
                                    <small class="d-block text-muted">Giờ Vào Ca</small>
                                    <strong class="text-success"><fmt:formatDate value="${todayCompletedShift.gioVao}" pattern="HH:mm:ss" /></strong>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-2 border rounded text-center bg-light">
                                    <small class="d-block text-muted">Giờ Ra Ca</small>
                                    <strong class="text-danger"><fmt:formatDate value="${todayCompletedShift.gioRa}" pattern="HH:mm:ss" /></strong>
                                </div>
                            </div>
                        </div>

                        <div class="mt-auto text-center text-muted small pt-3 border-top">
                            <i class="bi bi-clock-history me-1"></i>Tổng thời gian đã làm: <strong class="text-dark">${todayCompletedShift.soGioLam} giờ</strong>
                        </div>
                    </div>
                </c:when>

                <c:otherwise>
                    <!-- Trường hợp: CHƯA VÀO CA HÔM NAY HOẶC ĐÃ RA CA -->
                    <div class="card border-0 shadow-sm p-4 h-100 rounded-4" style="background-color: white;">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <h5 class="fw-bold text-dark mb-0"><i class="bi bi-box-arrow-in-right text-success me-2"></i>Chấm Công Vào Ca</h5>
                            <span class="badge bg-secondary-subtle text-dark border">Hệ thống nhận diện tự động</span>
                        </div>

                        <form action="${pageContext.request.contextPath}/staff/attendance" method="post">
                            <input type="hidden" name="action" value="checkin">

                            <div class="mb-3">
                                <label for="tenCaSelect" class="form-label fw-semibold text-secondary">
                                    Chọn Ca Làm Việc:
                                </label>
                                <select class="form-select form-select-lg rounded-3 border-secondary-subtle" id="tenCaSelect" name="tenCa">
                                    <option value="Ca Sáng (07:00 - 13:00)" ${currentShiftConfig.shiftName.contains('Sáng') ? 'selected' : ''}>
                                        Ca Sáng (07:00 - 13:00)
                                    </option>
                                    <option value="Ca Chiều (14:00 - 19:00)" ${currentShiftConfig.shiftName.contains('Chiều') ? 'selected' : ''}>
                                        Ca Chiều (14:00 - 19:00)
                                    </option>
                                    <option value="Ca Tối (19:30 - 22:30)" ${currentShiftConfig.shiftName.contains('Đêm') || currentShiftConfig.shiftName.contains('Tối') ? 'selected' : ''}>
                                        Ca Tối (19:30 - 22:30)
                                    </option>
                                    <option value="Ca Linh Hoạt" ${currentShiftConfig.shiftName.contains('Linh') || (not empty todayCompletedShift && todayCompletedShift.tenCa.contains('Linh')) ? 'selected' : ''}>
                                        ⚡ Ca Linh Hoạt (Tự do thời gian 00:00 - 23:59)
                                    </option>
                                </select>
                                <div class="form-text text-muted">
                                    <i class="bi bi-shield-check text-success me-1"></i>
                                    Với <strong>Ca Linh Hoạt</strong>, nhân viên có thể làm việc bất kỳ khung giờ nào trong ngày không bị giới hạn ca.
                                </div>
                            </div>

                            <!-- Quy định khung ca -->
                            <div class="row g-2 mb-4">
                                <div class="col-3">
                                    <div class="p-2 border rounded text-center bg-light">
                                        <small class="d-block text-muted">Ca Sáng</small>
                                        <strong class="text-dark" style="font-size: 0.8rem;">07:00-13:00</strong>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded text-center bg-light">
                                        <small class="d-block text-muted">Ca Chiều</small>
                                        <strong class="text-dark" style="font-size: 0.8rem;">14:00-19:00</strong>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded text-center bg-light">
                                        <small class="d-block text-muted">Ca Tối</small>
                                        <strong class="text-dark" style="font-size: 0.8rem;">19:30-22:30</strong>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded text-center bg-warning bg-opacity-10 border-warning">
                                        <small class="d-block text-warning-emphasis fw-semibold">Ca Linh Hoạt</small>
                                        <strong class="text-warning-emphasis" style="font-size: 0.8rem;">Tự do giờ</strong>
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-success btn-lg w-100 py-3 rounded-3 fw-bold shadow">
                                <i class="bi bi-play-circle-fill me-2"></i>BẮT ĐẦU VÀO CA (CHECK-IN)
                            </button>
                        </form>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Thống kê cá nhân trong tháng -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 rounded-4 bg-white text-center">
                <small class="text-muted d-block mb-1 fw-semibold">Tổng Ca Trong Tháng</small>
                <h3 class="fw-bold text-dark my-0">${totalShiftsThisMonth} <small class="fs-6 text-muted">ca</small></h3>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 rounded-4 bg-white text-center">
                <small class="text-muted d-block mb-1 fw-semibold">Tổng Số Giờ Làm</small>
                <h3 class="fw-bold text-primary my-0">${totalHoursThisMonth} <small class="fs-6 text-muted">giờ</small></h3>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 rounded-4 bg-white text-center">
                <small class="text-muted d-block mb-1 fw-semibold">Đi Làm Đúng Giờ</small>
                <h3 class="fw-bold text-success my-0">${onTimeCount} <small class="fs-6 text-muted">lần</small></h3>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 rounded-4 bg-white text-center">
                <small class="text-muted d-block mb-1 fw-semibold">Đi Muộn / Về Sớm</small>
                <h3 class="fw-bold text-warning my-0">${lateCount} <small class="fs-6 text-muted">lần</small></h3>
            </div>
        </div>
    </div>

    <!-- Lịch sử chấm công cá nhân -->
    <div class="card border-0 shadow-sm rounded-4 p-4 bg-white mb-4">
        <div class="d-flex align-items-center justify-content-between mb-3">
            <h5 class="fw-bold text-dark mb-0">
                <i class="bi bi-clock-history me-2 text-warning"></i>Lịch Sử Chấm Công Cá Nhân
            </h5>
            <span class="badge bg-secondary-subtle text-dark border">${personalHistory.size()} lượt gần nhất</span>
        </div>

        <div class="table-responsive">
            <table class="table align-middle table-hover">
                <thead class="table-light">
                    <tr>
                        <th>Ngày Chấm Công</th>
                        <th>Ca Làm Việc</th>
                        <th class="text-center">Giờ Vào</th>
                        <th class="text-center">Giờ Ra</th>
                        <th class="text-center">Số Giờ Làm</th>
                        <th class="text-center">Trạng Thái</th>
                        <th>Ghi Chú</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="att" items="${personalHistory}">
                        <tr>
                            <td>
                                <strong class="text-dark">
                                    <fmt:formatDate value="${att.ngayChamCong}" pattern="dd/MM/yyyy" />
                                </strong>
                            </td>
                            <td>
                                <span class="fw-semibold text-secondary">${att.tenCa}</span>
                            </td>
                            <td class="text-center text-success fw-semibold">
                                <c:choose>
                                    <c:when test="${not empty att.gioVao}">
                                        <fmt:formatDate value="${att.gioVao}" pattern="HH:mm:ss" />
                                    </c:when>
                                    <c:otherwise>--:--</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center text-danger fw-semibold">
                                <c:choose>
                                    <c:when test="${not empty att.gioRa}">
                                        <fmt:formatDate value="${att.gioRa}" pattern="HH:mm:ss" />
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-success-subtle text-success border">Đang làm việc</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <span class="badge bg-light text-dark border px-2.5 py-1.5 fw-bold">
                                    ${att.soGioLam} giờ
                                </span>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${att.trangThai == 'CoMat'}">
                                        <span class="badge bg-success-subtle text-success border rounded-pill px-3 py-1">
                                            <i class="bi bi-check-circle-fill me-1"></i>Có mặt
                                        </span>
                                    </c:when>
                                    <c:when test="${att.trangThai == 'DiMuon'}">
                                        <span class="badge bg-warning-subtle text-warning border rounded-pill px-3 py-1">
                                            <i class="bi bi-clock-history me-1"></i>Đi muộn
                                        </span>
                                    </c:when>
                                    <c:when test="${att.trangThai == 'VeSom'}">
                                        <span class="badge bg-warning-subtle text-warning border rounded-pill px-3 py-1" style="color: #fd7e14 !important;">
                                            <i class="bi bi-box-arrow-left me-1"></i>Về sớm
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary-subtle text-secondary border rounded-pill px-3 py-1">${att.trangThai}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">
                                ${not empty att.ghiChu ? att.ghiChu : '-'}
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty personalHistory}">
                        <tr>
                            <td colspan="7" class="text-center py-5 text-muted">
                                <i class="bi bi-inbox fs-2 d-block mb-2 opacity-50"></i>
                                Bạn chưa có lượt chấm công nào trong hệ thống. Hãy bấm nút <strong>VÀO CA (CHECK-IN)</strong> ở trên!
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal Xác Nhận Kết Thúc Ca Làm -->
<c:if test="${not empty activeShift}">
    <div class="modal fade" id="confirmCheckoutModal" tabindex="-1" aria-labelledby="confirmCheckoutModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 shadow border-0">
                <div class="modal-header bg-dark text-white rounded-top-4">
                    <h5 class="modal-title fw-bold text-warning mb-0" id="confirmCheckoutModalLabel">
                        <i class="bi bi-box-arrow-right text-danger me-2"></i>Xác Nhận Kết Thúc Ca Làm
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="rounded-circle bg-danger bg-opacity-10 d-inline-flex align-items-center justify-content-center p-3 mb-3" style="width: 75px; height: 75px;">
                        <i class="bi bi-stopwatch-fill text-danger display-5"></i>
                    </div>

                    <h5 class="fw-bold text-dark mb-2">Bạn có chắc muốn KẾT THÚC RA CA ngay bây giờ?</h5>
                    <p class="text-secondary small mb-3">
                        Ca làm hiện tại: <strong class="text-dark">${activeShift.tenCa}</strong><br>
                        Thời gian vào ca: <strong class="text-success"><fmt:formatDate value="${activeShift.gioVao}" pattern="HH:mm:ss" /></strong>
                    </p>

                    <div class="alert alert-warning border-0 bg-warning bg-opacity-10 text-dark small py-2 mb-0 rounded-3">
                        <i class="bi bi-info-circle-fill text-warning me-1"></i>
                        Hệ thống sẽ tự động tính tổng số giờ làm việc thực tế từ lúc vào ca đến thời điểm này.
                    </div>
                </div>
                <div class="modal-footer bg-light rounded-bottom-4 justify-content-center gap-2">
                    <button type="button" class="btn btn-outline-secondary px-4 rounded-3" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" form="checkoutForm" class="btn btn-danger px-4 rounded-3 fw-bold shadow-sm">
                        <i class="bi bi-check-circle-fill me-1"></i>Xác nhận Ra Ca
                    </button>
                </div>
            </div>
        </div>
    </div>
</c:if>

<!-- JavaScript Đồng Hồ Kỹ Thuật Số Realtime -->
<script>
    function updateClock() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        
        document.getElementById('liveClockTime').innerText = hours + ':' + minutes + ':' + seconds;

        const options = { weekday: 'long', year: 'numeric', month: '2-digit', day: '2-digit' };
        const dateStr = now.toLocaleDateString('vi-VN', options);
        document.getElementById('liveClockDate').innerText = dateStr;
        document.getElementById('todayDateStr').innerText = now.toLocaleDateString('vi-VN');
    }

    setInterval(updateClock, 1000);
    updateClock();
</script>

<!-- Nhúng Footer dùng chung phía Nhân viên -->
<jsp:include page="common/staff-footer.jsp" />
