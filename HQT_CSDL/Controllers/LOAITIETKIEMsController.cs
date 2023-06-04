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
    public class LOAITIETKIEMsController : Controller
    {
        private Entities1 db = new Entities1();

        // GET: LOAITIETKIEMs
        public ActionResult Index()
        {
            return View(db.LOAITIETKIEMs.ToList());
        }

        // GET: LOAITIETKIEMs/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            LOAITIETKIEM lOAITIETKIEM = db.LOAITIETKIEMs.Find(id);
            if (lOAITIETKIEM == null)
            {
                return HttpNotFound();
            }
            return View(lOAITIETKIEM);
        }

        // GET: LOAITIETKIEMs/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: LOAITIETKIEMs/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "MALOAITK,TENLOAITK,KYHAN,LAISUAT")] LOAITIETKIEM lOAITIETKIEM)
        {
            if (ModelState.IsValid)
            {
                db.LOAITIETKIEMs.Add(lOAITIETKIEM);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(lOAITIETKIEM);
        }

        // GET: LOAITIETKIEMs/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            LOAITIETKIEM lOAITIETKIEM = db.LOAITIETKIEMs.Find(id);
            if (lOAITIETKIEM == null)
            {
                return HttpNotFound();
            }
            return View(lOAITIETKIEM);
        }

        // POST: LOAITIETKIEMs/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "MALOAITK,TENLOAITK,KYHAN,LAISUAT")] LOAITIETKIEM lOAITIETKIEM)
        {
            if (ModelState.IsValid)
            {
                db.Entry(lOAITIETKIEM).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(lOAITIETKIEM);
        }

        // GET: LOAITIETKIEMs/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            LOAITIETKIEM lOAITIETKIEM = db.LOAITIETKIEMs.Find(id);
            if (lOAITIETKIEM == null)
            {
                return HttpNotFound();
            }
            return View(lOAITIETKIEM);
        }

        // POST: LOAITIETKIEMs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            LOAITIETKIEM lOAITIETKIEM = db.LOAITIETKIEMs.Find(id);
            db.LOAITIETKIEMs.Remove(lOAITIETKIEM);
            db.SaveChanges();
            return RedirectToAction("Index");
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
