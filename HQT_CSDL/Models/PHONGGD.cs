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
    
    public partial class PHONGGD
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public PHONGGD()
        {
            this.QUAYGDs = new HashSet<QUAYGD>();
        }
    
        public string MAPGD { get; set; }
        public string TENPGD { get; set; }
        public string DIACHI { get; set; }
        public string LIENHE { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<QUAYGD> QUAYGDs { get; set; }
    }
}