using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using HQT_CSDL.Models;
using Oracle.ManagedDataAccess.Client;

namespace HQT_CSDL.Controllers
{
    public class KHACHHANGsController : Controller
    {
        private Entities1 db = new Entities1();
        public ActionResult Index()
        {
            return View(db.KHACHHANGs.Where(s => s.TINHTRANG == "Y").ToList());
        }

        // GET: KHACHHANGs/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            KHACHHANG kHACHHANG = db.KHACHHANGs.Find(id);
            if (kHACHHANG == null)
            {
                return HttpNotFound();
            }
            return View(kHACHHANG);
        }

        // GET: KHACHHANGs/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: KHACHHANGs/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "MAKH,HOTEN,GIOITINH,NGAYSINH,CCCD,DIACHI,SDT,TINHTRANG")] KHACHHANG kHACHHANG)
        {
            try
            {
                db.THEM_KHACH_HANG(kHACHHANG.MAKH, kHACHHANG.HOTEN, kHACHHANG.GIOITINH, kHACHHANG.NGAYSINH, kHACHHANG.CCCD, kHACHHANG.DIACHI, kHACHHANG.SDT, "Y");
                return RedirectToAction("Index");
            } catch (Exception ex)
            {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình thêm khách hàng";
                ViewBag.Style = "red";
                return View(kHACHHANG);
            }

           
        }

        // GET: KHACHHANGs/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            KHACHHANG kHACHHANG = db.KHACHHANGs.Find(id);
            if (kHACHHANG == null)
            {
                return HttpNotFound();
            }
            return View(kHACHHANG);
        }

        // POST: KHACHHANGs/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "MAKH,HOTEN,GIOITINH,NGAYSINH,CCCD,DIACHI,SDT,TINHTRANG")] KHACHHANG kHACHHANG)
        {
            try
            {
                db.UPDATE_CUSTOMER_INFO(kHACHHANG.MAKH, kHACHHANG.HOTEN, kHACHHANG.GIOITINH, kHACHHANG.NGAYSINH, kHACHHANG.CCCD, kHACHHANG.DIACHI, kHACHHANG.SDT, kHACHHANG.TINHTRANG);
                return RedirectToAction("Index");
            }
            catch (DbUpdateException trg)
            {
                var errorMessage = trg.InnerException?.Message;
                ViewBag.ErrorMessage = errorMessage;
                return View(kHACHHANG);
            }
            catch (Exception ex)
            {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình sửa khách hàng";
                ViewBag.Style = "red";
                return View(kHACHHANG);
            }
        }

        // GET: KHACHHANGs/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            KHACHHANG kHACHHANG = db.KHACHHANGs.Find(id);
            if (kHACHHANG == null)
            {
                return HttpNotFound();
            }
            return View(kHACHHANG);
        }

        // POST: KHACHHANGs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            try
            {
                db.XOA_KHACH_HANG(id);
                return RedirectToAction("Index");

            }
            catch (DbUpdateException ex)
            {
                if (ex.InnerException is OracleException oracleEx && oracleEx.Number == 1031)
                {
                    
                }
                return View(id);
            }
            catch (Exception ex)
            {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình xóa khách hàng";
                ViewBag.Style = "red";
                return View(id);
            }
            
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
