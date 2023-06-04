using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using HQT_CSDL.Models;

namespace HQT_CSDL.Controllers
{
    public class NHANVIENsController : Controller
    {
        private Entities1 db = new Entities1();

        // GET: NHANVIENs
        public ActionResult Index()
        {
            var nHANVIENs = db.NHANVIENs.Where(s => s.TINHTRANG == "Y").Include(n => n.QUAYGD);
            return View(nHANVIENs.ToList());
        }

        // GET: NHANVIENs/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            NHANVIEN nHANVIEN = db.NHANVIENs.Find(id);
            if (nHANVIEN == null)
            {
                return HttpNotFound();
            }
            return View(nHANVIEN);
        }

        // GET: NHANVIENs/Create
        public ActionResult Create()
        {
            ViewBag.MAQUAY = new SelectList(db.QUAYGDs, "MAQUAY", "MAPGD");
            ViewBag.MAPQ = new SelectList(db.CHUCVUs, "MACV", "TENCV");
            return View();
        }

        // POST: NHANVIENs/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "MANV,HOTEN,GIOITINH,NGAYSINH,CCCD,DIACHI,SDT,TINHTRANG,MAQUAY")] NHANVIEN nHANVIEN, string TENDANGNHAP, string MATKHAU, string MAPQ)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    db.SP_THEMNHANVIEN(nHANVIEN.HOTEN, nHANVIEN.GIOITINH, nHANVIEN.NGAYSINH, nHANVIEN.CCCD, nHANVIEN.DIACHI, nHANVIEN.SDT
                        , nHANVIEN.MAQUAY, TENDANGNHAP, MATKHAU, MAPQ);
                    return RedirectToAction("Index");
                }
                

                ViewBag.MAQUAY = new SelectList(db.QUAYGDs, "MAQUAY", "MAPGD", nHANVIEN.MAQUAY);

                return View(nHANVIEN);
            }
            catch (Exception ex)
            {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình thêm nhân viên";
                ViewBag.Style = "red";
                return View(nHANVIEN);
            }
        }

        // GET: NHANVIENs/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            NHANVIEN nHANVIEN = db.NHANVIENs.Find(id);
            if (nHANVIEN == null)
            {
                return HttpNotFound();
            }
            ViewBag.MAQUAY = new SelectList(db.QUAYGDs, "MAQUAY", "MAPGD", nHANVIEN.MAQUAY);
            return View(nHANVIEN);
        }

        // POST: NHANVIENs/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "MANV,HOTEN,GIOITINH,NGAYSINH,CCCD,DIACHI,SDT,TINHTRANG,MAQUAY")] NHANVIEN nHANVIEN)
        {
            try {
               
                db.SUATHONGTINNHANVIEN(nHANVIEN.MANV, nHANVIEN.HOTEN, nHANVIEN.GIOITINH, nHANVIEN.NGAYSINH, nHANVIEN.CCCD, nHANVIEN.DIACHI, nHANVIEN.SDT, nHANVIEN.TINHTRANG, nHANVIEN.MAQUAY);
                return RedirectToAction("Index");
        
            } catch (Exception ex) {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình sửa thông tin nhân viên";
                ViewBag.Style = "red";
                ViewBag.MAQUAY = new SelectList(db.QUAYGDs, "MAQUAY", "MAPGD", nHANVIEN.MAQUAY);
                return View(nHANVIEN);
            }
        }

        // GET: NHANVIENs/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            NHANVIEN nHANVIEN = db.NHANVIENs.Find(id);
            if (nHANVIEN == null)
            {
                return HttpNotFound();
            }
            return View(nHANVIEN);
        }

        // POST: NHANVIENs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            try {
                db.DELETE_EMPLOYEE(id);
                return RedirectToAction("Index");
            } catch (Exception ex)
            {
                ViewBag.Msg = "Có lỗi " + ex.Message + " trong quá trình xóa nhân viên";
                ViewBag.Style = "red";
                NHANVIEN nHANVIEN = db.NHANVIENs.Find(id);
                return View(nHANVIEN);
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
