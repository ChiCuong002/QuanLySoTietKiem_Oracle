//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace HQT_CSDL.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class LOAIHINHGD
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public LOAIHINHGD()
        {
            this.GIAODICHes = new HashSet<GIAODICH>();
        }
    
        public string MALOAIGD { get; set; }
        public string LOAIHINHGIAODICH { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<GIAODICH> GIAODICHes { get; set; }
    }
}