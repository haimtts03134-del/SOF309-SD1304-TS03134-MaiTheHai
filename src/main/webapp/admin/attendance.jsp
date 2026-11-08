<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung -->
<jsp:include page="common/header.jsp" />

<div class="container-fluid px-0">
    <!-- Tiêu đề trang -->
    <div class="row mb-4 align-items-center">
        <div class="col-md-7">
            <h2 class="fw-bold text-dark"><i class="bi bi-calendar-check-fill text-warning me-2"></i>Quản Lý Chấm Công & Ca Làm</h2>
            <p class="text-muted mb-0">Theo dõi sự có mặt, điểm danh ca làm việc, thời gian vào/ra và tính tổng số giờ làm của nhân viên.</p>
        </div>
        <div class="col-md-5 text-md-end mt-3 mt-md-0">
            <span class="badge bg-success-subtle text-success border border-success rounded-pill px-3 py-2 me-2 shadow-sm">
                <i class="bi bi-broadcast me-1"></i> Tự động cập nhật (1.5s)
            </span>
            <button type="button" class="btn btn-warning fw-semibold shadow-sm text-dark" data-bs-toggle="modal" data-bs-target="#quickBatchModal">
                <i class="bi bi-lightning-charge-fill me-1"></i> Điểm danh nhanh tất cả (Hôm nay)
            </button>
        </div>
    </div>

    <!-- Thông báo lỗi nếu có -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Thất bại!</strong> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Thống kê tổng quan dạng Cards -->
    <div class="row g-3 mb-4">
        <!-- Tổng số NV hoạt động -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100 p-3" style="background: linear-gradient(135deg, #2b5876 0%, #4e4376 100%); color: #fff;">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-white-50 small fw-semibold">Tổng Nhân Viên</span>
                        <h3 class="fw-bold my-1">${totalEmployees}</h3>
                        <small class="text-white-50" style="font-size: 0.75rem;">Đang hoạt động</small>
                    </div>
                    <div class="rounded-circle p-3 bg-white bg-opacity-10 fs-3">
                        <i class="bi bi-people"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Số NV Có mặt -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100 p-3" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: #fff;">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-white-50 small fw-semibold">Có Mặt Đúng Giờ</span>
                        <h3 class="fw-bold my-1">${coMatCount}</h3>
                        <small class="text-white-50" style="font-size: 0.75rem;">Ngày ${selectedDateStr}</small>
                    </div>
                    <div class="rounded-circle p-3 bg-white bg-opacity-10 fs-3">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Số NV Đi muộn / Về sớm -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100 p-3" style="background: linear-gradient(135deg, #ff9966 0%, #ff5e62 100%); color: #fff;">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-white-50 small fw-semibold">Đi Muộn / Về Sớm</span>
                        <h3 class="fw-bold my-1">${diMuonCount + veSomCount}</h3>
                        <small class="text-white-50" style="font-size: 0.75rem;">Đi muộn: ${diMuonCount} | Về sớm: ${veSomCount}</small>
                    </div>
                    <div class="rounded-circle p-3 bg-white bg-opacity-10 fs-3">
                        <i class="bi bi-exclamation-circle-fill"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Số NV Vắng mặt / Nghỉ phép -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm rounded-4 h-100 p-3" style="background: linear-gradient(135deg, #cb2d3e 0%, #ef473a 100%); color: #fff;">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-white-50 small fw-semibold">Vắng / Nghỉ Phép</span>
                        <h3 class="fw-bold my-1">${vangCount + nghiPhepCount}</h3>
                        <small class="text-white-50" style="font-size: 0.75rem;">Vắng: ${vangCount} | Phép: ${nghiPhepCount}</small>
                    </div>
                    <div class="rounded-circle p-3 bg-white bg-opacity-10 fs-3">
                        <i class="bi bi-x-circle-fill"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Thanh lọc theo ngày & từ khóa -->
    <div class="custom-card p-3 mb-4">
        <form action="${pageContext.request.contextPath}/admin/attendance" method="get" class="row g-3 align-items-center">
            <input type="hidden" name="action" value="list">
            
            <div class="col-12 col-md-4 col-lg-3">
                <label for="dateFilter" class="form-label mb-1 text-secondary fw-semibold" style="font-size: 0.85rem;">
                    <i class="bi bi-calendar-date me-1"></i>Chọn ngày xem:
                </label>
                <input type="date" class="form-control" id="dateFilter" name="date" value="${selectedDateStr}" onchange="this.form.submit();">
            </div>

            <div class="col-12 col-md-5 col-lg-4">
                <label for="keywordInput" class="form-label mb-1 text-secondary fw-semibold" style="font-size: 0.85rem;">
                    <i class="bi bi-search me-1"></i>Tìm kiếm nhân viên:
                </label>
                <div class="input-group">
                    <input type="text" class="form-control" id="keywordInput" name="keyword" 
                           placeholder="Nhập họ tên, email..." value="${keyword}">
                    <button class="btn btn-outline-secondary" type="submit">
                        <i class="bi bi-search"></i> Lọc
                    </button>
                </div>
            </div>

            <div class="col-12 col-md-3 col-lg-5 text-md-end align-self-end">
                <a href="${pageContext.request.contextPath}/admin/attendance" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-clockwise me-1"></i>Hôm nay
                </a>
            </div>
        </form>
    </div>

    <div class="row g-4">
        <!-- Bảng danh sách chấm công (Chiếm 8/12 cột) -->
        <div class="col-12 col-lg-8">
            <div class="custom-card">
                <div class="card-title-container">
                    <h5 class="custom-card-title">
                        <i class="bi bi-table me-2 text-warning"></i>Bảng Chấm Công (Ngày ${selectedDateStr})
                    </h5>
                    <span class="badge bg-secondary-subtle text-dark border">${attendanceList.size()} bản ghi</span>
                </div>

                <div class="table-responsive">
                    <table class="table custom-table align-middle">
                        <thead>
                            <tr>
                                <th style="width: 60px;">Ảnh</th>
                                <th>Nhân Viên</th>
                                <th>Ca Làm Việc</th>
                                <th class="text-center">Vào / Ra</th>
                                <th class="text-center">Giờ Làm</th>
                                <th class="text-center">Trạng Thái</th>
                                <th class="text-center" style="width: 90px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="att" items="${attendanceList}">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty att.user.hinhAnh}">
                                                <c:set var="userImg" value="${att.user.hinhAnh}" />
                                                <c:if test="${!att.user.hinhAnh.startsWith('http') && !att.user.hinhAnh.startsWith('data:') && !att.user.hinhAnh.startsWith('/')}">
                                                    <c:set var="userImg" value="${pageContext.request.contextPath}/admin/images/${att.user.hinhAnh}" />
                                                </c:if>
                                                <img src="${userImg}" class="rounded-circle border shadow-sm" style="width: 42px; height: 42px; object-fit: cover;" alt="${att.user.hoTen}" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100';">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded-circle border bg-light text-muted d-flex align-items-center justify-content-center shadow-sm" style="width: 42px; height: 42px;">
                                                    <i class="bi bi-person fs-5"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${att.user.hoTen}</div>
                                        <small class="text-muted d-block" style="font-size: 0.78rem;">${att.user.email}</small>
                                    </td>
                                    <td>
                                        <span class="fw-semibold text-secondary">${att.tenCa}</span>
                                        <c:if test="${not empty att.ghiChu}">
                                            <small class="d-block text-muted fst-italic" style="font-size: 0.75rem;">Note: ${att.ghiChu}</small>
                                        </c:if>
                                    </td>
                                    <td class="text-center">
                                        <div class="small fw-semibold text-dark">
                                            <i class="bi bi-box-arrow-in-right text-success me-1"></i>
                                            <c:choose>
                                                <c:when test="${not empty att.gioVao}">
                                                    <fmt:formatDate value="${att.gioVao}" pattern="HH:mm" />
                                                </c:when>
                                                <c:otherwise>--:--</c:otherwise>
                                            </c:choose>
                                            <span class="mx-1 text-muted">-</span>
                                            <i class="bi bi-box-arrow-right text-danger me-1"></i>
                                            <c:choose>
                                                <c:when test="${not empty att.gioRa}">
                                                    <fmt:formatDate value="${att.gioRa}" pattern="HH:mm" />
                                                </c:when>
                                                <c:otherwise>--:--</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-light text-dark border px-2 py-1">${att.soGioLam} giờ</span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${att.trangThai == 'CoMat'}">
                                                <span class="badge bg-success-subtle text-success border rounded-pill px-2.5 py-1">
                                                    <i class="bi bi-check-circle-fill me-1"></i>Có mặt
                                                </span>
                                            </c:when>
                                            <c:when test="${att.trangThai == 'DiMuon'}">
                                                <span class="badge bg-warning-subtle text-warning border rounded-pill px-2.5 py-1">
                                                    <i class="bi bi-clock-history me-1"></i>Đi muộn
                                                </span>
                                            </c:when>
                                            <c:when test="${att.trangThai == 'VeSom'}">
                                                <span class="badge bg-orange-subtle text-warning border rounded-pill px-2.5 py-1" style="color: #fd7e14 !important;">
                                                    <i class="bi bi-box-arrow-left me-1"></i>Về sớm
                                                </span>
                                            </c:when>
                                            <c:when test="${att.trangThai == 'Vang'}">
                                                <span class="badge bg-danger-subtle text-danger border rounded-pill px-2.5 py-1">
                                                    <i class="bi bi-x-circle-fill me-1"></i>Vắng mặt
                                                </span>
                                            </c:when>
                                            <c:when test="${att.trangThai == 'NghiPhep'}">
                                                <span class="badge bg-info-subtle text-info border rounded-pill px-2.5 py-1">
                                                    <i class="bi bi-person-slash me-1"></i>Nghỉ phép
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary-subtle text-secondary border rounded-pill px-2.5 py-1">${att.trangThai}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <!-- Nút sửa bản ghi -->
                                        <a href="${pageContext.request.contextPath}/admin/attendance?action=edit&id=${att.maChamCong}&date=${selectedDateStr}" 
                                           class="btn btn-sm btn-outline-warning action-btn me-1" title="Chỉnh sửa">
                                            <i class="bi bi-pencil-square"></i>
                                        </a>
                                        <!-- Nút xóa bản ghi -->
                                        <button type="button" class="btn btn-sm btn-outline-danger action-btn" title="Xóa"
                                                onclick="confirmDeleteAttendance(${att.maChamCong}, '<c:out value="${att.user.hoTen}" escapeXml="true"/>', '${selectedDateStr}')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty attendanceList}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-calendar-x fs-1 d-block mb-3 text-secondary opacity-50"></i>
                                        Chưa có bản ghi chấm công nào cho ngày <strong>${selectedDateStr}</strong>.<br>
                                        Hãy thêm mới ở biểu mẫu bên phải hoặc sử dụng tính năng 
                                        <a href="javascript:void(0);" data-bs-toggle="modal" data-bs-target="#quickBatchModal" class="fw-bold text-warning">Điểm danh nhanh</a>!
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Form Thêm / Cập nhật lượt chấm công (Chiếm 4/12 cột) -->
        <div class="col-12 col-lg-4">
            <div class="form-card">
                <h5 class="fw-bold mb-4 border-bottom pb-2">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <i class="bi bi-pencil-square text-warning me-2"></i>Cập Nhật Chấm Công
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-plus-circle-fill text-success me-2"></i>Thêm Lượt Chấm Công
                        </c:otherwise>
                    </c:choose>
                </h5>

                <form action="${pageContext.request.contextPath}/admin/attendance" method="post">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${selectedAttendance.maChamCong}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="insert">
                        </c:otherwise>
                    </c:choose>

                    <!-- Chọn nhân viên -->
                    <div class="mb-3">
                        <label for="maNguoiDung" class="form-label">Chọn Nhân Viên <span class="text-danger">*</span></label>
                        <select class="form-select" id="maNguoiDung" name="maNguoiDung" required>
                            <option value="" disabled ${empty selectedAttendance ? 'selected' : ''}>-- Chọn nhân viên --</option>
                            <c:forEach var="emp" items="${employees}">
                                <c:if test="${emp.trangThai == 'HoatDong'}">
                                    <option value="${emp.maNguoiDung}" ${selectedAttendance.user.maNguoiDung == emp.maNguoiDung ? 'selected' : ''}>
                                        ${emp.hoTen} (${emp.role.tenVaiTro})
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Ngày chấm công -->
                    <div class="mb-3">
                        <label for="ngayChamCong" class="form-label">Ngày chấm công <span class="text-danger">*</span></label>
                        <c:choose>
                            <c:when test="${not empty selectedAttendance}">
                                <fmt:formatDate value="${selectedAttendance.ngayChamCong}" pattern="yyyy-MM-dd" var="formattedDateVal" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="formattedDateVal" value="${selectedDateStr}" />
                            </c:otherwise>
                        </c:choose>
                        <input type="date" class="form-control" id="ngayChamCong" name="ngayChamCong" value="${formattedDateVal}" required>
                    </div>

                    <!-- Ca làm việc -->
                    <div class="mb-3">
                        <label for="tenCa" class="form-label">Ca làm việc <span class="text-danger">*</span></label>
                        <select class="form-select" id="tenCa" name="tenCa" required>
                            <c:set var="currentCa" value="${selectedAttendance.tenCa}" />
                            <option value="Ca Sáng (07:00 - 13:00)" ${currentCa == 'Ca Sáng (07:00 - 13:00)' || empty currentCa ? 'selected' : ''}>Ca Sáng (07:00 - 13:00)</option>
                            <option value="Ca Chiều (14:00 - 19:00)" ${currentCa == 'Ca Chiều (14:00 - 19:00)' ? 'selected' : ''}>Ca Chiều (14:00 - 19:00)</option>
                            <option value="Ca Tối (19:30 - 22:30)" ${currentCa == 'Ca Tối (19:30 - 22:30)' || currentCa == 'Ca Đêm (17:30 - 20:00)' ? 'selected' : ''}>Ca Tối (19:30 - 22:30)</option>
                            <option value="Ca Linh Hoạt" ${currentCa == 'Ca Linh Hoạt' ? 'selected' : ''}>Ca Linh Hoạt</option>
                        </select>
                    </div>

                    <!-- Giờ vào và Giờ ra -->
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label for="gioVao" class="form-label">Giờ vào ca</label>
                            <fmt:formatDate value="${selectedAttendance.gioVao}" pattern="HH:mm" var="gioVaoVal" />
                            <input type="time" class="form-control" id="gioVao" name="gioVao" value="${gioVaoVal}">
                        </div>
                        <div class="col-6">
                            <label for="gioRa" class="form-label">Giờ ra ca</label>
                            <fmt:formatDate value="${selectedAttendance.gioRa}" pattern="HH:mm" var="gioRaVal" />
                            <input type="time" class="form-control" id="gioRa" name="gioRa" value="${gioRaVal}">
                        </div>
                    </div>

                    <!-- Số giờ làm thực tế -->
                    <div class="mb-3">
                        <label for="soGioLam" class="form-label">Số giờ làm (Để trống để tự tính)</label>
                        <input type="number" step="0.1" min="0" max="24" class="form-control" id="soGioLam" name="soGioLam" 
                               placeholder="Ví dụ: 8.0" value="${selectedAttendance.soGioLam > 0 ? selectedAttendance.soGioLam : ''}">
                    </div>

                    <!-- Trạng thái -->
                    <div class="mb-3">
                        <label for="trangThai" class="form-label">Trạng thái đi làm <span class="text-danger">*</span></label>
                        <c:set var="statusVal" value="${selectedAttendance.trangThai}" />
                        <select class="form-select" id="trangThai" name="trangThai" required>
                            <option value="CoMat" ${statusVal == 'CoMat' || empty statusVal ? 'selected' : ''}>Có mặt (Đúng giờ)</option>
                            <option value="DiMuon" ${statusVal == 'DiMuon' ? 'selected' : ''}>Đi muộn</option>
                            <option value="VeSom" ${statusVal == 'VeSom' ? 'selected' : ''}>Về sớm</option>
                            <option value="Vang" ${statusVal == 'Vang' ? 'selected' : ''}>Vắng mặt (Không phép)</option>
                            <option value="NghiPhep" ${statusVal == 'NghiPhep' ? 'selected' : ''}>Nghỉ phép (Có phép)</option>
                        </select>
                    </div>

                    <!-- Ghi chú -->
                    <div class="mb-3">
                        <label for="ghiChu" class="form-label">Ghi chú thêm</label>
                        <input type="text" class="form-control" id="ghiChu" name="ghiChu" 
                               placeholder="Lý do đi muộn / xin nghỉ..." value="${selectedAttendance.ghiChu}">
                    </div>

                    <!-- Nút hành động -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-coffee flex-grow-1">
                            <i class="bi bi-cloud-arrow-up-fill me-2"></i>Lưu Chấm Công
                        </button>
                        <c:if test="${isEdit}">
                            <a href="${pageContext.request.contextPath}/admin/attendance?date=${selectedDateStr}" class="btn btn-outline-secondary">
                                Hủy
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Modal Điểm Danh Nhanh Hàng Loạt -->
<div class="modal fade" id="quickBatchModal" tabindex="-1" aria-labelledby="quickBatchModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 shadow border-0">
            <div class="modal-header bg-dark text-white rounded-top-4">
                <h5 class="modal-header-title fw-bold text-warning mb-0" id="quickBatchModalLabel">
                    <i class="bi bi-lightning-charge-fill me-2"></i>Điểm Danh Nhanh Tất Cả Nhân Viên
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/attendance" method="post">
                <input type="hidden" name="action" value="quick-batch">
                <div class="modal-body p-4">
                    <p class="text-secondary" style="font-size: 0.9rem;">
                        Hệ thống sẽ tự động tạo bản ghi điểm danh <strong>"Có mặt"</strong> cho toàn bộ nhân viên đang hoạt động chưa được chấm công trong ngày chọn.
                    </p>
                    
                    <div class="mb-3">
                        <label for="batchDate" class="form-label fw-semibold">Chọn ngày điểm danh:</label>
                        <input type="date" class="form-control" id="batchDate" name="batchDate" value="${selectedDateStr}" required>
                    </div>

                    <div class="mb-3">
                        <label for="defaultCa" class="form-label fw-semibold">Gán ca mặc định:</label>
                        <select class="form-select" id="defaultCa" name="defaultCa">
                            <option value="Ca Sáng (07:00 - 13:00)" selected>Ca Sáng (07:00 - 13:00)</option>
                            <option value="Ca Chiều (14:00 - 19:00)">Ca Chiều (14:00 - 19:00)</option>
                            <option value="Ca Tối (19:30 - 22:30)">Ca Tối (19:30 - 22:30)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer bg-light rounded-bottom-4">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-warning fw-bold">
                        <i class="bi bi-check-all me-1"></i>Xác nhận điểm danh tất cả
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Xác Nhận Xóa Chấm Công -->
<div class="modal fade" id="deleteAttendanceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header bg-danger text-white py-3">
                <h5 class="modal-title fw-bold d-flex align-items-center fs-6">
                    <i class="bi bi-trash3-fill text-white fs-5 me-2"></i>Xác Nhận Xóa Chấm Công
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center p-4">
                <i class="bi bi-exclamation-triangle-fill text-danger fs-1 d-block mb-2"></i>
                <p class="mb-1 text-dark">Bạn có chắc chắn muốn xóa bản ghi chấm công của nhân viên <strong id="deleteAttEmpName" class="text-danger">...</strong>?</p>
                <small class="text-muted d-block mt-1" style="font-size: 0.78rem;">Hành động này không thể hoàn tác.</small>
            </div>
            <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2 justify-content-center">
                <button type="button" class="btn btn-light border flex-grow-1 py-2 rounded-pill fw-semibold" data-bs-dismiss="modal">Hủy</button>
                <a id="confirmDeleteAttBtn" href="#" class="btn btn-danger flex-grow-1 py-2 rounded-pill fw-bold shadow-sm">Xóa Ngay</a>
            </div>
        </div>
    </div>
</div>

<script>
    function confirmDeleteAttendance(attId, empName, dateStr) {
        document.getElementById("deleteAttEmpName").innerText = empName;
        document.getElementById("confirmDeleteAttBtn").href = "${pageContext.request.contextPath}/admin/attendance?action=delete&id=" + attId + "&date=" + encodeURIComponent(dateStr);
        
        const modalEl = document.getElementById('deleteAttendanceModal');
        if (modalEl) {
            const modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
            modal.show();
        }
    }
</script>

<!-- Nhúng Footer dùng chung -->
<jsp:include page="common/footer.jsp" />
