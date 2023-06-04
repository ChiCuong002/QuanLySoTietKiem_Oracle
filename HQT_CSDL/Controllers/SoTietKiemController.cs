using HQT_CSDL.Models;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity.Core.Objects;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace HQT_CSDL.Controllers
{
    public class SoTietKiemController : Controller
    {
        Entities1 db = new Entities1();
        //public SoTietKiemController()
        //{
        //    // Retrieve the connection string
        //    string connectionString = ConfigurationManager.ConnectionStrings["Entities1"].ConnectionString;
        //    var userID = Session["USERID"];
        //    var pass =  Session["PASSWORD"];
        //    // Modify the connection string
        //    string modifiedConnectionString = connectionString.Replace("USER ID=PLSTK","USER ID=" + userID.ToString() )
        //                                                      .Replace("PASSWORD=1", "PASSWORD=" +pass.ToString());

        //    // Create the Entities1 object using the modified connection string
        //    db = new Entities1(modifiedConnectionString);
        //}
        // GET: SoTietKiem
        public ActionResult Index()
        {
          
            return View(db.SOTIETKIEMs.Where(s => s.TINHTRANG == "Y").ToList());
        }
        public ActionResult Details(string id)
        {
            return View(db.SOTIETKIEMs.Where(s => s.MASTK == id).FirstOrDefault());
        }
        [HttpGet]
        public ActionResult GuiTien(string id)
        {
            ViewBag.STK = id;
            return View();
        }
        [HttpPost]
        public ActionResult GuiTien(string MASTK, decimal SOTIEN_HIDDEN)
        {
            try
            {
                NHANVIEN nv = Session["NV"] as NHANVIEN;
                int kq = db.SP_GUITIEN(SOTIEN_HIDDEN, nv.MANV, MASTK);
                if (kq == -1)
                    ViewBag.Msg = "Gửi thêm tiền tiết kiệm thành công";
                else
                    ViewBag.Msg = "Có lỗi trong quá trình gửi tiền tiết kiệm";
                return View("GuiTien", null, new { id = MASTK });
            }
            catch
            {
                return View();
            }

        }
        [HttpGet]
        public ActionResult RutTien(string id)
        {
            ViewBag.STK = id;
            ViewBag.SOTIEN = db.SOTIETKIEMs.Where(s => s.MASTK == id).FirstOrDefault().SOTIENGUI;
            ViewBag.Msg = TempData["Msg"];
            ViewBag.Style = TempData["style"];
            return View();
        }
        [HttpPost]
        public ActionResult RutTien(string MASTK, decimal SOTIEN_HIDDEN)
        {
            try
            {
                NHANVIEN nv = Session["NV"] as NHANVIEN;
                var errorCodeParameter = new ObjectParameter("v_ERRORCODE", typeof(decimal));
                int result = db.SP_RUTTIEN(MASTK, SOTIEN_HIDDEN, nv.MANV, errorCodeParameter);
                var errorCode = (decimal)errorCodeParameter.Value;
                if (errorCode == 0)
                {
                    TempData["Msg"] = "Rút tiền tiết kiệm thành công. Số tiền nhận được là " + SOTIEN_HIDDEN + " VNĐ";
                    TempData["style"] = "green";
                    return RedirectToAction("RutTien", new { id = MASTK });
                }
                else if (errorCode == 1)
                {
                    TempData["Msg"] = "Lỗi số tiền trong sổ tiết kiệm không đủ";
                    TempData["style"] = "red";
                }
                else if (errorCode == 2)
                {
                    TempData["Msg"] = "Lỗi khóa ngoại mã số tiết kiệm";
                    TempData["style"] = "red";
                }
                else if (errorCode == 3)
                {
                    TempData["Msg"] = "Lỗi khóa ngoại mã nhân viên";
                    TempData["style"] = "red";
                }
                else
                {
                    TempData["Msg"] = "Có lỗi xảy ra";
                    TempData["style"] = "red";
                }
                return RedirectToAction("RutTien", new { id = MASTK });
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMsg = "Có lỗi xảy ra: " + ex.Message;

                // Trả về view GuiTien với thông báo lỗi
                return View("RutTien", new { id = MASTK });
            }
        }
        public string SOTIENLAI(string maSTK)
        {
            string result = db.Database.SqlQuery<string>("select f_soTienLai(:maSTK) from dual", new OracleParameter("maSTK", maSTK)).FirstOrDefault();
            return result ?? "0";
        }

        public string SOTHANGGUI(string maSTK)
        {
            string result = db.Database.SqlQuery<string>("select f_soThangGui(:maSTK) from dual", new OracleParameter("maSTK", maSTK)).FirstOrDefault();
            return result ?? "0";
        }

        [HttpGet]
        public ActionResult TatToan(string id)
        {
            try
            {
                ViewBag.Msg = TempData["Msg"];
                ViewBag.Style = TempData["style"];
                string sotienlai = SOTIENLAI(id);
                string sothanhgui = SOTHANGGUI(id);
                ViewBag.SOTIENLAI = sotienlai;
                ViewBag.SOTHANG = sothanhgui;
                return View(db.SOTIETKIEMs.Where(s => s.MASTK == id).FirstOrDefault());
            }
            catch (Exception ex)
            {
                return View();
            }
        }
        [HttpPost]
        public ActionResult XacNhan(string id)
        {
            try
            {
                NHANVIEN nv = Session["NV"] as NHANVIEN;
                var kq = new ObjectParameter("v_KQ", typeof(decimal));
                var sotien = new ObjectParameter("v_SOTIEN", typeof(decimal));
                db.SP_TATTOANSTK(id, nv.MANV, kq, sotien );
                var errorCode = (decimal)kq.Value;
                var sotienNhan = (decimal)sotien.Value;
                if (errorCode == 1)
                {
                    TempData["style"] = "green";
                    TempData["Msg"] = "Tất toán đúng thời hạn thành công. Số tiền khách hàng được nhận là: " + String.Format("{0:N0}", sotienNhan) + " VNĐ";
                } else if (errorCode == 2)
                {
                    TempData["style"] = "green";
                    TempData["Msg"] = "Tất toán trước thời hạn thành công. Số tiền khách hàng được nhận là: " + String.Format("{0:N0}", sotienNhan) + " VNĐ";
                } else if (errorCode == 3 || errorCode == 4)
                {
                    TempData["style"] = "red";
                    TempData["Msg"] = "Có lỗi trong quá trình tất toán. Hãy kiểm tra lại";
                }
                return RedirectToAction("TatToan", new { id = id });
            } catch (Exception ex)
            {
                TempData["style"] = "red";
                TempData["Msg"] = "Có lỗi " + ex.Message + " trong quá trình tất toán. Hãy kiểm tra lại";
                return RedirectToAction("TatToan", new { id = id });
            }
        }
        [HttpGet]
        public ActionResult MoSo()
        {
            ViewBag.MAKH = new SelectList(db.KHACHHANGs.Where(s => s.TINHTRANG == "Y"), "MAKH", "HOTEN");
            ViewBag.MALOAITK = new SelectList(db.LOAITIETKIEMs, "MALOAITK", "TENLOAITK");
            ViewBag.MANV = new SelectList(db.NHANVIENs.Where(s => s.TINHTRANG == "Y"), "MANV", "HOTEN");
            return View();
        }
        [HttpPost]
        public ActionResult MoSo(string MAKH, DateTime NGAYMOSO, decimal SOTIENGUI, string MALOAITK, string MANV)
        {
            try { 
                db.THEM_SO_TIET_KIEM(MAKH, NGAYMOSO, NGAYMOSO, SOTIENGUI, MALOAITK, MANV);
                ViewBag.Msg = "Mở sổ tiết kiệm thành công";
                ViewBag.Style = "red";
            } catch (Exception ex)
            {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình mở sổ tiết kiệm";
                ViewBag.Style = "red";
            }
            ViewBag.MAKH = new SelectList(db.KHACHHANGs, "MAKH", "HOTEN");
            ViewBag.MALOAITK = new SelectList(db.LOAITIETKIEMs, "MALOAITK", "TENLOAITK");
            ViewBag.MANV = new SelectList(db.NHANVIENs, "MANV", "HOTEN");
            return View();
        }
        [HttpGet]
        public ActionResult LSGD(string id)
        {
            return View(db.GIAODICHes.Where(s => s.MASTK == id).ToList());
        }
    }
}   