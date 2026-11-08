<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp" />

<div class="container-fluid px-0">
    <!-- Tiêu đề trang & Thông báo -->
    <div class="row mb-3 align-items-center">
        <div class="col-md-7">
            <h2 class="fw-bold text-dark"><i class="bi bi-receipt text-warning me-2"></i>Quản Lý Hóa Đơn Chi Tiết</h2>
            <p class="text-muted mb-0">Quản lý toàn bộ hóa đơn trong ngày hoặc lọc theo khoảng thời gian, xem chi tiết, thêm, chỉnh sửa thông tin và xóa hóa đơn.</p>
        </div>
        <div class="col-md-5 text-md-end mt-3 mt-md-0">
            <button type="button" class="btn btn-warning px-3 py-2 fw-bold shadow-sm" style="border-radius: 10px;" data-bs-toggle="modal" data-bs-target="#addInvoiceModal">
                <i class="bi bi-plus-circle-fill me-1"></i> Tạo Hóa Đơn Mới
            </button>
        </div>
    </div>

    <!-- Alert Thông báo thành công / Thất bại -->
    <c:if test="${not empty sessionScope.adminSuccess}">
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.adminSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% session.removeAttribute("adminSuccess"); %>
    </c:if>
    <c:if test="${not empty sessionScope.adminError}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.adminError}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% session.removeAttribute("adminError"); %>
    </c:if>

    <!-- Khối Bộ lọc Ngày & Trạng thái -->
    <div class="custom-card mb-4 p-3 bg-white shadow-sm" style="border-radius: 12px;">
        <form action="${pageContext.request.contextPath}/admin/invoices" method="get" id="filterForm" class="row g-3 align-items-center">
            <div class="col-12 col-md-4 col-lg-3">
                <label class="form-label fw-semibold small mb-1 text-secondary"><i class="bi bi-calendar-date me-1"></i> Chọn Ngày Xem Hóa Đơn:</label>
                <div class="input-group">
                    <input type="date" name="date" class="form-control" value="${selectedDate}" onchange="document.getElementById('filterForm').submit();">
                    <c:if test="${selectedDate != 'all'}">
                        <a href="${pageContext.request.contextPath}/admin/invoices?date=all&status=${selectedStatus}" class="btn btn-outline-secondary" title="Xem tất cả các ngày">Tất cả</a>
                    </c:if>
                </div>
            </div>

            <div class="col-12 col-md-5 col-lg-4">
                <label class="form-label fw-semibold small mb-1 text-secondary"><i class="bi bi-funnel me-1"></i> Lọc Trạng Thái Hóa Đơn:</label>
                <select name="status" class="form-select" onchange="document.getElementById('filterForm').submit();">
                    <option value="All" ${selectedStatus == 'All' ? 'selected' : ''}>Tất Cả Trạng Thái</option>
                    <option value="ChoThanhToan" ${selectedStatus == 'ChoThanhToan' ? 'selected' : ''}>Chờ Thanh Toán</option>
                    <option value="DangCheBien" ${selectedStatus == 'DangCheBien' ? 'selected' : ''}>Đang Chế Biến</option>
                    <option value="DaGiao" ${selectedStatus == 'DaGiao' ? 'selected' : ''}>Đã Giao Món</option>
                    <option value="DaThanhToan" ${selectedStatus == 'DaThanhToan' ? 'selected' : ''}>Đã Thanh Toán</option>
                    <option value="DaHuy" ${selectedStatus == 'DaHuy' ? 'selected' : ''}>Đã Hủy</option>
                </select>
            </div>

            <div class="col-12 col-md-3 col-lg-5 text-md-end pt-md-4">
                <% 
                    java.text.SimpleDateFormat sdfToday = new java.text.SimpleDateFormat("yyyy-MM-dd");
                    String todayStr = sdfToday.format(new java.util.Date());
                    pageContext.setAttribute("todayStr", todayStr);
                %>
                <a href="${pageContext.request.contextPath}/admin/invoices?date=${todayStr}" class="btn btn-sm ${selectedDate == todayStr ? 'btn-warning text-dark fw-bold' : 'btn-outline-warning text-dark'} me-1" style="border-radius: 8px;">
                    <i class="bi bi-clock-history me-1"></i> Hôm Nay
                </a>
                <a href="${pageContext.request.contextPath}/admin/invoices?date=all&status=All" class="btn btn-sm ${(selectedDate == 'all' && (empty selectedStatus || selectedStatus == 'All')) ? 'btn-dark fw-bold' : 'btn-outline-dark'}" style="border-radius: 8px;">
                    <i class="bi bi-calendar3 me-1"></i> Tất Cả Hóa Đơn
                </a>
            </div>
        </form>
    </div>

    <!-- Các thẻ Thống kê KPI Nhanh -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 bg-white" style="border-radius: 12px; border-left: 4px solid #0d6efd !important;">
                <span class="text-muted small fw-semibold">TỔNG HÓA ĐƠN</span>
                <h3 class="fw-bold text-dark mb-0 mt-1">${totalOrdersCount} <small class="fs-6 text-muted fw-normal">đơn</small></h3>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 bg-white" style="border-radius: 12px; border-left: 4px solid #198754 !important;">
                <span class="text-muted small fw-semibold">TỔNG DOANH THU</span>
                <h3 class="fw-bold text-success mb-0 mt-1">
                    <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                </h3>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 bg-white" style="border-radius: 12px; border-left: 4px solid #ffc107 !important;">
                <span class="text-muted small fw-semibold">ĐÃ THANH TOÁN</span>
                <h3 class="fw-bold text-warning mb-0 mt-1">${completedCount} <small class="fs-6 text-muted fw-normal">đơn</small></h3>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm p-3 bg-white" style="border-radius: 12px; border-left: 4px solid #dc3545 !important;">
                <span class="text-muted small fw-semibold">ĐANG XỬ LÝ / HỦY</span>
                <h3 class="fw-bold text-secondary mb-0 mt-1">${pendingCount} <small class="fs-6 text-muted fw-normal">chờ</small> / <span class="text-danger">${cancelledCount}</span> <small class="fs-6 text-muted fw-normal">hủy</small></h3>
            </div>
        </div>
    </div>

    <!-- Bảng Danh Sách Hóa Đơn -->
    <div class="custom-card shadow-sm p-0 overflow-hidden" style="border-radius: 12px;">
        <div class="p-3 bg-white border-bottom d-flex align-items-center justify-content-between">
            <h5 class="custom-card-title mb-0">
                <i class="bi bi-list-stars text-warning me-2"></i>Danh Sách Hóa Đơn (${orders.size()})
            </h5>
            <span class="badge bg-light text-dark border">
                <c:choose>
                    <c:when test="${selectedDate == 'all'}">Tất cả ngày</c:when>
                    <c:otherwise>Ngày: ${selectedDate}</c:otherwise>
                </c:choose>
            </span>
        </div>

        <div class="table-responsive">
            <table id="invoiceTable" class="table table-hover align-middle custom-table mb-0">
                <thead class="bg-light">
                    <tr>
                        <th style="width: 80px;" class="ps-3">Mã HĐ</th>
                        <th>Thời Gian Đặt</th>
                        <th>Hình Thức / Vị Trí</th>
                        <th>Khách Hàng</th>
                        <th>Nhân Viên Phụ Trách</th>
                        <th class="text-end">Tổng Tiền</th>
                        <th class="text-center">Trạng Thái</th>
                        <th class="text-center" style="width: 220px;">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="order" items="${orders}">
                        <tr>
                            <td class="ps-3">
                                <strong class="text-dark">#${order.maHoaDon}</strong>
                            </td>
                            <td>
                                <span class="text-muted small">
                                    <fmt:formatDate value="${order.ngayTao}" pattern="dd/MM/yyyy HH:mm:ss" />
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${order.loaiHoaDon == 'TaiCho'}">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                                            <i class="bi bi-shop me-1"></i> ${not empty order.table ? order.table.tenBan : 'Tại quán'}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill">
                                            <i class="bi bi-bag-dash me-1"></i> Mang về
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty order.customer}">
                                        <div class="fw-semibold text-dark">${order.customer.hoTen}</div>
                                        <small class="text-muted"><i class="bi bi-telephone me-1"></i>${order.customer.soDienThoai}</small>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted italic">Khách vãng lai</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty order.user}">
                                        <span class="text-secondary small">
                                            <i class="bi bi-person-badge me-1"></i>${order.user.hoTen}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted small fst-italic">Chưa gán</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end fw-bold text-dark">
                                <fmt:formatNumber value="${order.tongTien}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${order.trangThai == 'ChoThanhToan'}">
                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #fff3cd; color: #664d03; border: 1px solid #ffecb5; font-size: 0.82rem;"><i class="bi bi-clock-history me-1"></i>Chờ thanh toán</span>
                                    </c:when>
                                    <c:when test="${order.trangThai == 'DangCheBien'}">
                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #cff4fc; color: #055160; border: 1px solid #b6effb; font-size: 0.82rem;"><i class="bi bi-cup-hot-fill me-1"></i>Đang chế biến</span>
                                    </c:when>
                                    <c:when test="${order.trangThai == 'DaGiao'}">
                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #e0cffc; color: #3d0a91; border: 1px solid #c5b3f8; font-size: 0.82rem;"><i class="bi bi-send-check-fill me-1"></i>Đã giao món</span>
                                    </c:when>
                                    <c:when test="${order.trangThai == 'DaThanhToan'}">
                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; font-size: 0.82rem;"><i class="bi bi-check-circle-fill me-1"></i>Đã thanh toán</span>
                                    </c:when>
                                    <c:when test="${order.trangThai == 'DaHuy'}">
                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; font-size: 0.82rem;"><i class="bi bi-x-circle-fill me-1"></i>Đã hủy</span>
                                    </c:when>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <div class="d-flex justify-content-center gap-1">
                                    <button type="button" class="btn btn-sm btn-outline-info" title="Xem chi tiết hóa đơn" onclick="showInvoiceDetail(${order.maHoaDon})">
                                        <i class="bi bi-eye-fill"></i>
                                    </button>
                                    <button type="button" class="btn btn-sm btn-outline-warning" title="Sửa thông tin hóa đơn" onclick="showEditInvoiceModal(${order.maHoaDon})">
                                        <i class="bi bi-pencil-square"></i>
                                    </button>
                                    <button type="button" class="btn btn-sm btn-outline-danger" title="Xóa hóa đơn" onclick="confirmDeleteInvoice(${order.maHoaDon})">
                                        <i class="bi bi-trash-fill"></i>
                                    </button>
                                </div>

                                <div id="invoice-data-${order.maHoaDon}" class="d-none"
                                     data-id="${order.maHoaDon}"
                                     data-date="<fmt:formatDate value='${order.ngayTao}' pattern='dd/MM/yyyy HH:mm:ss' />"
                                     data-status="${order.trangThai}"
                                     data-type="${order.loaiHoaDon}"
                                     data-table-id="${order.table != null ? order.table.maBan : ''}"
                                     data-location="${order.loaiHoaDon == 'TaiCho' ? (not empty order.table ? order.table.tenBan : 'Tại quán') : 'Mang về'}"
                                     data-customer-name="${not empty order.customer ? order.customer.hoTen : 'Khách vãng lai'}"
                                     data-customer-phone="${not empty order.customer ? order.customer.soDienThoai : ''}"
                                     data-staff-name="${not empty order.user ? order.user.hoTen : 'Chưa gán'}"
                                     data-total="${order.tongTien}"
                                     data-formatted-total="<fmt:formatNumber value='${order.tongTien}' type='currency' currencySymbol='đ' maxFractionDigits='0' />"
                                     data-note="${order.ghiChu}">

                                    <div class="items-list">
                                        <c:forEach var="detail" items="${order.orderDetails}">
                                            <div class="d-flex align-items-center justify-content-between p-2 mb-2 bg-white rounded border">
                                                <div class="d-flex align-items-center gap-2">
                                                    <c:choose>
                                                        <c:when test="${not empty detail.drink && not empty detail.drink.hinhAnh}">
                                                            <c:set var="detailImg" value="${detail.drink.hinhAnh}" />
                                                            <c:if test="${!detail.drink.hinhAnh.startsWith('http') && !detail.drink.hinhAnh.startsWith('data:') && !detail.drink.hinhAnh.startsWith('/')}">
                                                                <c:set var="detailImg" value="${pageContext.request.contextPath}/admin/images/${detail.drink.hinhAnh}" />
                                                            </c:if>
                                                            <img src="${detailImg}" class="rounded border" style="width: 42px; height: 42px; object-fit: cover;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/${detail.drink.hinhAnh}';">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="rounded border bg-light text-muted d-flex align-items-center justify-content-center" style="width: 42px; height: 42px;">
                                                                <i class="bi bi-cup-hot fs-5"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <strong class="d-block text-dark" style="font-size: 0.95rem;">${not empty detail.drink ? detail.drink.tenSanPham : 'Sản phẩm không xác định'}</strong>
                                                        <small class="text-muted"><fmt:formatNumber value="${detail.donGia}" type="currency" currencySymbol="đ" maxFractionDigits="0" /> x ${detail.soLuong}</small>
                                                        <c:if test="${not empty detail.ghiChu}">
                                                            <small class="text-danger d-block fst-italic">*Y/c: ${detail.ghiChu}</small>
                                                        </c:if>
                                                    </div>
                                                </div>
                                                <span class="fw-bold text-success">
                                                    <fmt:formatNumber value="${detail.donGia * detail.soLuong}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                                </span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty orders}">
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                Không tìm thấy hóa đơn nào trong khoảng thời gian / bộ lọc đã chọn.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ================= MODAL XEM CHI TIẾT HÓA ĐƠN ================= -->
<div class="modal fade" id="detailInvoiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header bg-dark text-white py-3" style="border-radius: 16px 16px 0 0;">
                <h5 class="modal-title fw-bold" id="detailModalTitle">
                    <i class="bi bi-receipt me-2 text-warning"></i>Chi Tiết Hóa Đơn #0
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3 mb-4 p-3 bg-light rounded-3 border">
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-clock me-1"></i>Thời gian:</span>
                        <strong class="text-dark small" id="detailModalDate">---</strong>
                    </div>
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-shop me-1"></i>Hình thức / Vị trí:</span>
                        <strong class="text-success small" id="detailModalLocation">---</strong>
                    </div>
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-person me-1"></i>Khách hàng:</span>
                        <strong class="text-dark small" id="detailModalCustomer">---</strong>
                    </div>
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-person-badge me-1"></i>Nhân viên:</span>
                        <strong class="text-dark small" id="detailModalStaff">---</strong>
                    </div>
                </div>

                <h6 class="fw-bold mb-3 text-dark"><i class="bi bi-cup-straw text-warning me-2"></i>Danh Sách Món Đã Đặt:</h6>
                <div id="detailModalItemsContainer" class="mb-4" style="max-height: 250px; overflow-y: auto;">
                    <!-- JS injects items -->
                </div>

                <div class="mb-4 p-3 bg-light rounded border">
                    <span class="text-secondary small d-block mb-1"><i class="bi bi-pencil-square me-1"></i>Ghi chú hóa đơn:</span>
                    <span class="text-dark fw-semibold" id="detailModalNote">---</span>
                </div>

                <div class="d-flex justify-content-between align-items-center bg-success-subtle p-3 rounded-3 border border-success-subtle">
                    <span class="fs-6 text-success-emphasis fw-bold">TỔNG TIỀN HÓA ĐƠN:</span>
                    <span class="fs-3 fw-black text-success" id="detailModalTotal" style="font-weight: 800;">0 đ</span>
                </div>
            </div>
            <div class="modal-footer border-0 p-3 pt-0">
                <button type="button" class="btn btn-secondary px-4 py-2 fw-semibold" data-bs-dismiss="modal" style="border-radius: 10px;">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- ================= MODAL THÊM HÓA ĐƠN MỚI ================= -->
<div class="modal fade" id="addInvoiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header bg-warning text-dark py-3" style="border-radius: 16px 16px 0 0;">
                <h5 class="modal-title fw-bold">
                    <i class="bi bi-plus-circle-fill me-2"></i>Tạo Hóa Đơn Mới (Admin)
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/invoices" method="post">
                <input type="hidden" name="action" value="insert">
                <input type="hidden" name="date" value="${selectedDate}">

                <div class="modal-body p-4">
                    <div class="row g-3 mb-3">
                        <!-- Tên Khách Hàng (Tự nhận diện & Gợi ý) -->
                        <div class="col-md-6 position-relative">
                            <label class="form-label fw-semibold small text-secondary">Tên Khách Hàng:</label>
                            <input type="text" id="adminCustomerName" name="customerName" class="form-control" 
                                   placeholder="Nhập tên của khách (Tự gợi ý SĐT)" autocomplete="off">
                            <div id="adminCustomerSuggestions" class="dropdown-menu shadow-lg w-100 p-0 overflow-hidden mt-1 bg-white" 
                                 style="display:none; position:absolute; z-index:1050; border-radius: 12px; border: 1px solid rgba(0,112,74,0.2);">
                            </div>
                        </div>

                        <!-- Số Điện Thoại Khách Hàng -->
                        <div class="col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Số điện thoại Khách hàng:</label>
                            <div class="input-group">
                                <input type="text" id="adminCustomerPhone" name="customerPhone" class="form-control" 
                                       placeholder="Ví dụ: 0901234567" oninput="checkAdminCustomerPoints(this.value)">
                                <button type="button" class="btn btn-outline-success fw-semibold px-2" onclick="checkAdminCustomerPoints(document.getElementById('adminCustomerPhone').value)">
                                    <i class="bi bi-search me-1"></i> Tra cứu
                                </button>
                            </div>
                            <small id="adminCustomerStatusInfo" class="text-success fw-bold d-block mt-1" style="display:none;"></small>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small text-secondary">Hình thức gọi món:</label>
                            <select name="loaiHoaDon" class="form-select" onchange="toggleTableSelect(this.value, 'addTableSelectContainer')">
                                <option value="TaiCho">Tại Quán</option>
                                <option value="MangVe">Mang Về</option>
                            </select>
                        </div>
                        <div class="col-md-4" id="addTableSelectContainer">
                            <label class="form-label fw-semibold small text-secondary">Chọn Bàn Ngồi:</label>
                            <select name="tableId" class="form-select">
                                <option value="">-- Chọn bàn --</option>
                                <c:forEach var="t" items="${tables}">
                                    <option value="${t.maBan}">${t.tenBan} (${t.trangThai})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small text-secondary">Trạng Thái Ban Đầu:</label>
                            <select name="trangThai" class="form-select">
                                <option value="ChoThanhToan">Chờ Thanh Toán</option>
                                <option value="DangCheBien">Đang Chế Biến</option>
                                <option value="DaGiao">Đã Giao Món</option>
                                <option value="DaThanhToan">Đã Thanh Toán</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">Ghi chú đơn hàng:</label>
                        <input type="text" name="ghiChu" class="form-control" placeholder="Ghi chú chung...">
                    </div>

                    <hr class="my-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-cup-hot text-warning me-2"></i>Chọn Sản Phẩm / Đồ Uống:</h6>
                        <button type="button" class="btn btn-sm btn-outline-warning text-dark fw-bold" onclick="addDrinkRow()">
                            <i class="bi bi-plus-lg me-1"></i> Thêm Món
                        </button>
                    </div>

                    <div id="drinkRowsContainer" class="mb-3">
                        <!-- JS sẽ tạo các dòng chọn món ở đây -->
                    </div>
                </div>

                <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2">
                    <button type="button" class="btn btn-light border flex-grow-1 py-2 fw-semibold" data-bs-dismiss="modal" style="border-radius: 10px;">Hủy</button>
                    <button type="submit" class="btn btn-warning flex-grow-1 py-2 fw-bold" style="border-radius: 10px;">Lưu Hóa Đơn</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ================= MODAL SỬA HÓA ĐƠN ================= -->
<div class="modal fade" id="editInvoiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header bg-dark text-white py-3" style="border-radius: 16px 16px 0 0;">
                <h5 class="modal-title fw-bold">
                    <i class="bi bi-pencil-square text-warning me-2"></i>Chỉnh Sửa Hóa Đơn <span id="editModalDisplayId">#0</span>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/invoices" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" id="editModalOrderId">
                <input type="hidden" name="date" value="${selectedDate}">

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">Trạng Thái Hóa Đơn:</label>
                        <select name="trangThai" id="editModalStatus" class="form-select">
                            <option value="ChoThanhToan">Chờ Thanh Toán</option>
                            <option value="DangCheBien">Đang Chế Biến</option>
                            <option value="DaGiao">Đã Giao Món</option>
                            <option value="DaThanhToan">Đã Thanh Toán</option>
                            <option value="DaHuy">Đã Hủy</option>
                        </select>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold small text-secondary">Hình Thức:</label>
                            <select name="loaiHoaDon" id="editModalType" class="form-select">
                                <option value="TaiCho">Tại Quán</option>
                                <option value="MangVe">Mang Về</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold small text-secondary">Chọn Bàn:</label>
                            <select name="tableId" id="editModalTable" class="form-select">
                                <option value="">-- Mang về / Không chọn --</option>
                                <c:forEach var="t" items="${tables}">
                                    <option value="${t.maBan}">${t.tenBan}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">SĐT Khách Hàng:</label>
                        <input type="text" name="customerPhone" id="editModalPhone" class="form-control">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">Tổng Tiền (VNĐ):</label>
                        <input type="number" step="1000" name="tongTien" id="editModalTotal" class="form-control fw-bold text-success">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">Ghi Chú / Lý Do Hủy:</label>
                        <textarea name="ghiChu" id="editModalNote" class="form-control" rows="2"></textarea>
                    </div>
                </div>

                <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2">
                    <button type="button" class="btn btn-light border flex-grow-1 py-2 fw-semibold" data-bs-dismiss="modal" style="border-radius: 10px;">Hủy</button>
                    <button type="submit" class="btn btn-warning flex-grow-1 py-2 fw-bold" style="border-radius: 10px;">Cập Nhật</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ================= MODAL XÁC NHẬN XÓA ================= -->
<div class="modal fade" id="deleteInvoiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header bg-danger text-white py-3" style="border-radius: 16px 16px 0 0;">
                <h5 class="modal-title fw-bold">Xác Nhận Xóa</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center p-4">
                <i class="bi bi-exclamation-triangle-fill text-danger fs-1 d-block mb-2"></i>
                <p class="mb-1">Bạn có chắc chắn muốn xóa hóa đơn <strong id="deleteModalOrderId" class="text-danger">#0</strong>?</p>
                <small class="text-muted">Hành động này không thể hoàn tác.</small>
            </div>
            <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2">
                <button type="button" class="btn btn-light border flex-grow-1 py-2" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy</button>
                <a id="confirmDeleteLink" href="#" class="btn btn-danger flex-grow-1 py-2 fw-bold" style="border-radius: 8px;">Xóa Ngay</a>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. Hiển thị Modal Xem Chi Tiết
    function showInvoiceDetail(orderId) {
        const dataEl = document.getElementById("invoice-data-" + orderId);
        if (!dataEl) return;

        document.getElementById("detailModalTitle").innerHTML = '<i class="bi bi-receipt me-2 text-warning"></i>Chi Tiết Hóa Đơn #' + orderId;
        document.getElementById("detailModalDate").innerText = dataEl.getAttribute("data-date");
        document.getElementById("detailModalLocation").innerText = dataEl.getAttribute("data-location");
        document.getElementById("detailModalCustomer").innerText = dataEl.getAttribute("data-customer-name") + (dataEl.getAttribute("data-customer-phone") ? ' (' + dataEl.getAttribute("data-customer-phone") + ')' : '');
        document.getElementById("detailModalStaff").innerText = dataEl.getAttribute("data-staff-name");
        document.getElementById("detailModalTotal").innerText = dataEl.getAttribute("data-formatted-total");

        const note = dataEl.getAttribute("data-note");
        document.getElementById("detailModalNote").innerText = note ? note : 'Không có ghi chú.';

        const itemsListEl = dataEl.querySelector(".items-list");
        document.getElementById("detailModalItemsContainer").innerHTML = itemsListEl ? itemsListEl.innerHTML : '';

        const modalEl = document.getElementById('detailInvoiceModal');
        const modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
        modal.show();
    }

    // 2. Hiển thị Modal Chỉnh Sửa Hóa Đơn
    function showEditInvoiceModal(orderId) {
        const dataEl = document.getElementById("invoice-data-" + orderId);
        if (!dataEl) return;

        document.getElementById("editModalOrderId").value = orderId;
        document.getElementById("editModalDisplayId").innerText = '#' + orderId;
        document.getElementById("editModalStatus").value = dataEl.getAttribute("data-status");
        document.getElementById("editModalType").value = dataEl.getAttribute("data-type");
        document.getElementById("editModalTable").value = dataEl.getAttribute("data-table-id") || "";
        document.getElementById("editModalPhone").value = dataEl.getAttribute("data-customer-phone") || "";
        document.getElementById("editModalTotal").value = dataEl.getAttribute("data-total") || 0;
        document.getElementById("editModalNote").value = dataEl.getAttribute("data-note") || "";

        const modalEl = document.getElementById('editInvoiceModal');
        const modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
        modal.show();
    }

    // 3. Hiển thị Modal Xác Nhận Xóa
    function confirmDeleteInvoice(orderId) {
        document.getElementById("deleteModalOrderId").innerText = '#' + orderId;
        document.getElementById("confirmDeleteLink").href = "${pageContext.request.contextPath}/admin/invoices?action=delete&id=" + orderId + "&date=${selectedDate}";
        
        const modalEl = document.getElementById('deleteInvoiceModal');
        const modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
        modal.show();
    }

    // 4. Thêm dòng chọn sản phẩm động khi tạo hóa đơn mới
    function addDrinkRow() {
        const container = document.getElementById("drinkRowsContainer");
        const rowId = Date.now();
        
        let drinkOptionsHtml = '<option value="">-- Chọn món nước --</option>';
        <c:forEach var="d" items="${drinks}">
            drinkOptionsHtml += '<option value="${d.maSanPham}">${d.tenSanPham} - <fmt:formatNumber value="${d.giaCoBan}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></option>';
        </c:forEach>

        const rowDiv = document.createElement("div");
        rowDiv.className = "row g-2 mb-2 align-items-center p-2 bg-light rounded border";
        rowDiv.id = "drink-row-" + rowId;
        rowDiv.innerHTML = `
            <div class="col-6 col-md-5">
                <select name="drinkId" class="form-select form-select-sm" required>` + drinkOptionsHtml + `</select>
            </div>
            <div class="col-3 col-md-2">
                <input type="number" name="quantity" class="form-control form-select-sm" value="1" min="1" placeholder="SL" required>
            </div>
            <div class="col-9 col-md-4">
                <input type="text" name="itemNote" class="form-control form-select-sm" placeholder="Yêu cầu (Đá, đường...)">
            </div>
            <div class="col-3 col-md-1 text-end">
                <button type="button" class="btn btn-sm btn-outline-danger border-0" onclick="document.getElementById('drink-row-` + rowId + `').remove()">
                    <i class="bi bi-x-circle fs-6"></i>
                </button>
            </div>
        `;
        container.appendChild(rowDiv);
    }

    // Tự động thêm 1 dòng món ban đầu khi mở modal Thêm
    document.addEventListener("DOMContentLoaded", function() {
        const addModalEl = document.getElementById('addInvoiceModal');
        if (addModalEl) {
            addModalEl.addEventListener('show.bs.modal', function () {
                const container = document.getElementById("drinkRowsContainer");
                if (container.children.length === 0) {
                    addDrinkRow();
                }
            });
        }
    });

    function toggleTableSelect(type, containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.style.display = (type === 'MangVe') ? 'none' : 'block';
        }
    }

    // Tự động nhận diện & gợi ý Khách hàng theo Tên / SĐT ở Admin Modal
    let adminSearchTimeout = null;
    document.addEventListener("DOMContentLoaded", function() {
        const nameInput = document.getElementById("adminCustomerName");
        const suggestionsEl = document.getElementById("adminCustomerSuggestions");

        if (nameInput && suggestionsEl) {
            nameInput.addEventListener("input", function() {
                const query = this.value.trim();
                if (adminSearchTimeout) clearTimeout(adminSearchTimeout);

                if (query.length < 2) {
                    suggestionsEl.style.display = "none";
                    suggestionsEl.innerHTML = "";
                    return;
                }

                adminSearchTimeout = setTimeout(() => {
                    fetch('${pageContext.request.contextPath}/check-points?query=' + encodeURIComponent(query))
                        .then(res => res.json())
                        .then(data => {
                            suggestionsEl.innerHTML = "";
                            if (data && data.exists && data.customers && data.customers.length > 0) {
                                data.customers.forEach(cust => {
                                    const item = document.createElement("button");
                                    item.type = "button";
                                    item.className = "dropdown-item py-2 px-3 border-bottom text-start d-flex align-items-center justify-content-between";
                                    item.innerHTML = '<div>' +
                                        '<strong class="text-dark d-block"><i class="bi bi-person-circle text-success me-1"></i>' + cust.name + '</strong>' +
                                        '<small class="text-muted"><i class="bi bi-telephone me-1"></i>' + cust.phone + '</small>' +
                                        '</div>' +
                                        '<span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1 rounded-pill small">' +
                                        cust.points + ' điểm' +
                                        '</span>';
                                    item.onclick = function() {
                                        selectAdminCustomer(cust.name, cust.phone, cust.points);
                                    };
                                    suggestionsEl.appendChild(item);
                                });

                                if (data.customers.length === 1 && data.customers[0].name.toLowerCase() === query.toLowerCase()) {
                                    selectAdminCustomer(data.customers[0].name, data.customers[0].phone, data.customers[0].points);
                                } else {
                                    suggestionsEl.style.display = "block";
                                }
                            } else {
                                suggestionsEl.style.display = "none";
                            }
                        })
                        .catch(() => { suggestionsEl.style.display = "none"; });
                }, 200);
            });

            document.addEventListener("click", function(e) {
                if (!nameInput.contains(e.target) && !suggestionsEl.contains(e.target)) {
                    suggestionsEl.style.display = "none";
                }
            });
        }
    });

    function selectAdminCustomer(name, phone, points) {
        const nameInput = document.getElementById("adminCustomerName");
        const phoneInput = document.getElementById("adminCustomerPhone");
        const suggestionsEl = document.getElementById("adminCustomerSuggestions");
        const statusInfo = document.getElementById("adminCustomerStatusInfo");

        if (nameInput) nameInput.value = name;
        if (phoneInput) phoneInput.value = phone;
        if (suggestionsEl) suggestionsEl.style.display = "none";

        if (statusInfo) {
            statusInfo.style.display = "block";
            statusInfo.innerHTML = '<i class="bi bi-person-check-fill me-1"></i>Thành viên: <strong>' + name + '</strong> (' + (points || 0) + ' điểm)';
        }
    }

    function checkAdminCustomerPoints(phone) {
        if (!phone) return;
        phone = phone.trim();
        const phonePattern = /^(0[3|5|7|8|9])+([0-9]{8})$/;
        const statusInfo = document.getElementById("adminCustomerStatusInfo");

        if (!phonePattern.test(phone)) {
            if (statusInfo) statusInfo.style.display = "none";
            return;
        }

        fetch('${pageContext.request.contextPath}/check-points?phone=' + encodeURIComponent(phone))
            .then(res => res.json())
            .then(data => {
                if (data && data.exists) {
                    if (statusInfo) {
                        statusInfo.style.display = "block";
                        statusInfo.innerHTML = '<i class="bi bi-person-check-fill me-1"></i>Thành viên: <strong>' + data.name + '</strong> (' + (data.points || 0) + ' điểm)';
                    }
                    const nameInput = document.getElementById("adminCustomerName");
                    if (nameInput && !nameInput.value.trim()) {
                        nameInput.value = data.name;
                    }
                } else {
                    if (statusInfo) {
                        statusInfo.style.display = "block";
                        statusInfo.innerHTML = '<i class="bi bi-person-plus-fill me-1"></i>Khách hàng mới (Tự tạo khi lưu đơn)';
                    }
                }
            });
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
</script>

<jsp:include page="common/footer.jsp" />
