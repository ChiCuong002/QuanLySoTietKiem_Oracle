using HQT_CSDL.Models;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Web.Services.Description;

namespace HQT_CSDL.Controllers
{
    public class HomeController : Controller
    {
        Entities1 db = new Entities1();
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
        public ActionResult Login()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Login(string TENDANGNHAP, string MATKHAU)
        {
            Session["USERID"] = TENDANGNHAP;
            Session["PASSWORD"] = MATKHAU;
            var nhanvien = db.NHANVIENs.Where(s => s.TENDANGNHAP == TENDANGNHAP && s.MATKHAU == MATKHAU).FirstOrDefault();
            if (nhanvien != null)
            {
                Session["NV"] = nhanvien;
                if (nhanvien.MACV.Trim().Equals("QTV"))
                {
                    return RedirectToAction("Index","KHACHHANGs");
                }
                else if (nhanvien.MACV.Trim().Equals("GDV"))
                {
                    return RedirectToAction("Index", "SoTietKiem");
                }
                else
                {
                    return View();
                }
            }
            else
                ViewBag.Msg = "Tên đăng nhập hoặc mật khẩu không đúng";
                return View();
        }

        public ActionResult Logout()
        {
            // Xóa các session liên quan đến người dùng
            Session.Clear();
            return RedirectToAction("Login", "Home");
        }

    }
}