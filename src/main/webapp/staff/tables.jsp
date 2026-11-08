<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="common/staff-header.jsp" />

<div class="row mb-4">
    <div class="col-12">
        <h2 class="fw-bold text-dark"><i class="bi bi-grid-3x3-gap-fill text-warning me-2"></i>Sơ Đồ Bàn Ăn</h2>
        <p class="text-muted">Quản lý và cập nhật nhanh trạng thái các bàn nước (Trống / Đang có khách / Bảo trì).</p>
    </div>
</div>

<!-- Hiển thị thông báo thành công hoặc lỗi -->
<c:if test="${not empty sessionScope.tableSuccess}">
    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px;">
        <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.tableSuccess}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty sessionScope.tableError}">
    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px;">
        <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.tableError}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="row g-4">
    <c:forEach var="tbl" items="${tables}">
        <div class="col-12 col-sm-6 col-md-4 col-lg-3">
            <div class="card border-0 shadow-sm h-100" style="border-radius: 16px; overflow: hidden; transition: transform 0.2s;">
                <!-- Phần đầu của Card bàn -->
                <div class="card-header text-center py-4 border-0 
                    <c:choose>
                        <c:when test="${tbl.trangThai == 'Trong'}">bg-success bg-opacity-10 text-success</c:when>
                        <c:when test="${tbl.trangThai == 'CoKhach'}">bg-danger bg-opacity-10 text-danger</c:when>
                        <c:otherwise>bg-secondary bg-opacity-10 text-secondary</c:otherwise>
                    </c:choose>">
                    <i class="bi bi-shop fs-1 d-block mb-2"></i>
                    <h4 class="fw-bold m-0">${tbl.tenBan}</h4>
                </div>
                
                <!-- Phần thân Card -->
                <div class="card-body text-center p-3">
                    <div class="mb-3">
                        <span class="badge px-3 py-2 fs-6 rounded-pill
                            <c:choose>
                                <c:when test="${tbl.trangThai == 'Trong'}">bg-success bg-opacity-75 text-white</c:when>
                                <c:when test="${tbl.trangThai == 'CoKhach'}">bg-danger bg-opacity-75 text-white</c:when>
                                <c:otherwise>bg-secondary bg-opacity-75 text-white</c:otherwise>
                            </c:choose>">
                            <c:choose>
                                <c:when test="${tbl.trangThai == 'Trong'}"><i class="bi bi-circle-fill me-1 small"></i> Bàn Trống</c:when>
                                <c:when test="${tbl.trangThai == 'CoKhach'}"><i class="bi bi-people-fill me-1"></i> Có Khách</c:when>
                                <c:otherwise><i class="bi bi-tools me-1"></i> Bảo Trì</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    
                    <p class="text-muted small mb-0">Mã QR Code: <code>${tbl.maCodeQR}</code></p>
                </div>
                
                <!-- Nút thao tác ở chân Card -->
                <div class="card-footer bg-white border-0 p-3 pt-0">
                    <form action="${pageContext.request.contextPath}/staff/tables" method="post" class="d-grid gap-2">
                        <input type="hidden" name="tableId" value="${tbl.maBan}">
                        
                        <!-- Nút xem và in mã QR Code đặt món cho bàn -->
                        <button type="button" class="btn btn-outline-warning text-dark py-1.5 fw-bold mb-2" 
                                onclick="showQrModal('${tbl.tenBan}', '${tbl.maCodeQR}')" style="border-radius: 8px;">
                            <i class="bi bi-qr-code-scan me-1"></i> Xem & In Mã QR
                        </button>

                        <c:choose>
                            <c:when test="${tbl.trangThai == 'Trong'}">
                                <input type="hidden" name="status" value="CoKhach">
                                <button type="submit" class="btn btn-danger py-2 fw-bold" style="border-radius: 8px;">
                                    <i class="bi bi-people-fill me-1"></i> Đổi sang Có Khách
                                </button>
                            </c:when>
                            <c:when test="${tbl.trangThai == 'CoKhach'}">
                                <input type="hidden" name="status" value="Trong">
                                <button type="submit" class="btn btn-success py-2 fw-bold" style="border-radius: 8px;">
                                    <i class="bi bi-check-circle me-1"></i> Đổi sang Bàn Trống
                                </button>
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="status" value="Trong">
                                <button type="submit" class="btn btn-success py-2 fw-bold" style="border-radius: 8px;">
                                    <i class="bi bi-wrench me-1"></i> Kết Thúc Bảo Trì (Trống)
                                </button>
                            </c:otherwise>
                        </c:choose>
                        
                        <!-- Lựa chọn chuyển sang bảo trì nhanh -->
                        <c:if test="${tbl.trangThai != 'BaoTri'}">
                            <button type="button" class="btn btn-sm btn-outline-secondary py-1" 
                                    onclick="changeToMaintenance(${tbl.maBan}, '${tbl.tenBan}');" style="border-radius: 6px; font-size: 0.8rem;">
                                <i class="bi bi-tools me-1"></i> Báo Bảo Trì
                            </button>
                        </c:if>
                    </form>
                </div>
            </div>
        </div>
    </c:forEach>
</div>

<!-- Modal Hiển thị & In QR Code Đặt Món -->
<div class="modal fade" id="qrModal" tabindex="-1" aria-labelledby="qrModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered text-center">
        <div class="modal-content shadow border-0" style="border-radius: 16px;">
            <div class="modal-header border-0 bg-dark text-warning p-3">
                <h5 class="modal-title fw-bold" id="qrModalTitle"><i class="bi bi-qr-code me-2"></i>Mã QR Đặt Món</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4" id="printableQrArea">
                <div class="p-3 border rounded-3 bg-light d-inline-block shadow-sm mb-3">
                    <h3 class="fw-bold text-dark mb-1" id="qrTableName">Bàn 1</h3>
                    <p class="text-muted small mb-3">Quét mã QR để mở thực đơn & đặt món tại bàn</p>
                    <img id="qrImage" src="" alt="QR Code" class="img-fluid rounded shadow-sm" style="width: 220px; height: 220px; object-fit: contain;">
                    <div class="mt-3">
                        <small class="text-secondary d-block">Đường dẫn quét đặt món:</small>
                        <code class="text-break small fw-bold text-primary" id="qrFullUrl">http://...</code>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 p-3 pt-0 justify-content-center gap-2">
                <button type="button" class="btn btn-secondary px-4 fw-semibold" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
                <button type="button" class="btn btn-warning px-4 fw-bold text-dark" onclick="window.print()" style="border-radius: 8px;">
                    <i class="bi bi-printer me-1"></i> In Mã QR Bàn
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Form ẩn dùng để gửi yêu cầu chuyển trạng thái bảo trì -->
<form id="maintenanceForm" action="${pageContext.request.contextPath}/staff/tables" method="post" style="display: none;">
    <input type="hidden" name="tableId" id="maintenanceTableId">
    <input type="hidden" name="status" value="BaoTri">
</form>

<script>
    function changeToMaintenance(tableId, tableName) {
        if (confirm("Bạn có chắc chắn muốn đưa " + tableName + " vào trạng thái Bảo trì? Khách hàng sẽ không thể đặt món tại bàn này.")) {
            document.getElementById("maintenanceTableId").value = tableId;
            document.getElementById("maintenanceForm").submit();
        }
    }

    function showQrModal(tableName, qrCode) {
        document.getElementById('qrTableName').textContent = tableName;
        document.getElementById('qrModalTitle').innerHTML = '<i class="bi bi-qr-code me-2"></i>Mã QR Đặt Món - ' + tableName;
        
        // Tạo đường dẫn URL đầy đủ tới trang menu của bàn
        const baseUrl = window.location.protocol + "//" + window.location.host + "${pageContext.request.contextPath}/menu?table=" + qrCode;
        document.getElementById('qrFullUrl').textContent = baseUrl;
        
        // Tạo ảnh QR Code động
        const qrApiUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=" + encodeURIComponent(baseUrl);
        document.getElementById('qrImage').src = qrApiUrl;
        
        const modal = new bootstrap.Modal(document.getElementById('qrModal'));
        modal.show();
    }
</script>

<%
    session.removeAttribute("tableSuccess");
    session.removeAttribute("tableError");
%>

<jsp:include page="common/staff-footer.jsp" />
