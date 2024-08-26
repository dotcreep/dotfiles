Untuk mengetahui permasalahan dan juga solusi pada setup NVIM, dokumen ini
sengaja saya buat agar tidak melupakan alasan mengapa membangun neovim dari
nol hingga digunakan sebagai alternatif beberapa code editor seperti 
- VSCode
- Replit

* Saya ingin membuat rapi, mudah dibaca
- Saya telah membuat struktur agar mudah dikelola

* Sepertinya menggunakan switcher seperti on off terhadap plugin lebih mudah
- Setiap fitur folder saya gunakan setup.lua untuk object on off pada
  parent setup.lua paling luar

* Saya butuh fitur menambahkan penutup pada simbol ", ', (, dan semacamnya
- Menggunakan plugin autopairs 

* Untuk membuka file saya membutuhkan file explorer
- Gunakan plugin nvim-tree

* Perlu perapian baris pada setiap line
- Gunakan plugin indent blackline

* Saya butuh autocompletion tetapi cepat, dan modul auto install pada bahasa
- Saya menggunakan mason + lsp sebagai tools ini, karena coc memiliki
  performa yang buruk. Maka secara manual saya gunakan mason dan lsp ini

* Saya suka lupa, jadi perlu catatan
- Folder docs digunakan sebagai untuk mencatat semua perihal yang diperlukan
  agar memastikan apa saja yang sudah saya lakukan, dan tujuannya untuk apa

* Perlu migrasikan ke git secara nyaman
- Gunakan nvim-fugitive, ini berfungsi sebagai tools intergrasi dengan git.
  Di poles juga dengan beberapa shortcut untuk eksekusi seperti <leader>gcp
  untuk mempermudah eksekusi push.

* Perlu tema tetapi bisa di switcher
- Tema yang dipasang oleh plugin dapat dipilah berdasarkan switcher di file
  parent setup.lua

* Cara membuka folder konfigurasi bagaimana?
- Metode ini dibuat dengan shortcut space-oc yang difungsikan sebagai pindah
  ke folder konfigurasi jika di inginkan merubah sesuatu secara cepat.


