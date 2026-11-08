package listener;

import dao.AttendanceDao;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.Date;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Listener chạy định kỳ tự động điểm danh kết thúc ca (Auto Check-out) cho nhân viên khi đến giờ kết thúc ca.
 */
@WebListener
public class AttendanceAutoCheckoutListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private AttendanceDao attendanceDao;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        attendanceDao = new AttendanceDao();
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // Chạy ngầm định kỳ 1 phút một lần để kiểm tra các ca làm quá giờ kết thúc
        scheduler.scheduleAtFixedRate(() -> {
            try {
                attendanceDao.autoCheckoutExpiredShifts(new Date());
            } catch (Exception e) {
                // Nuốt ngoại lệ để scheduler tiếp tục chạy
            }
        }, 10, 60, TimeUnit.SECONDS);

        System.out.println("[AttendanceAutoCheckoutListener] Da khoi tao tien trinh tu dong diem danh ket thuc ca (Auto Check-out).");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[AttendanceAutoCheckoutListener] Da dung tien trinh tu dong diem danh ket thuc ca.");
        }
    }
}
