I'm pretty fed up with the wrong perception of Zygisk "Zygisk is the next generation of hiding". So I leave these words here to correct the correct misrepresentations.

**What is Zygisk?**

Zygisk is the feature to run parts of Magisk in zygote daemon and also allow zygisk modules to inject code in every app processes inspired of Riru. Zygisk is released in Magisk v24, after MagiskHide is officially removed. Zygisk has DenyList to revoke almost Magisk modification from all apps on denylist. In additional, no zygisk modules will load for any app on denylist.

**Zygisk's weakness**

Zygisk seems to be powerful but that doesn't mean it will not have weakness. Unfortunately, due to the nature of Zygisk, it leaves very obvious traces in memory which any app can scan to detect zygisk plus it DOES NOT have hiding function. Keep in mind that, DenyList is not the replacement for MagiskHide. Nothing can replace MagiskHide functionality. DenyList is not the hiding feature for zygisk because it DOES NOT hide the existence of Zygisk.

**Any apps can discover Zygisk**

There are known apps have been reported that detect zygisk which will crash itself whenever Zygisk is enabled despite of what you are doing such as Livin’ by Madiri (id.bmri.livin), Itsme (be.bmid.itsme), InstaPay Engypt (com.egyptianbanks.instapay),… Even the hiding module use Zygisk API also cannot hide Zygisk from these apps.

**Final words**

In conclusion, Zygisk is not for hiding because of easily detected. If you are using Magisk Delta, in the most case, you don't need Zygisk to hide root. Please only enable Zygisk if you absolutely need it.
