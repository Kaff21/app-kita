const https = require('https');
const { spawn } = require('child_process');

console.log('========================================================');
console.log(' SoulSync Tunneling (Akses Antar Device / HP Jarak Jauh)');
console.log('========================================================\n');

// 1. Ambil password IP langsung via Node.js
console.log('[1] Mengambil password IP publik...');
const req = https.get('https://loca.lt/mytunnelpassword', { timeout: 6000 }, (res) => {
  let ip = '';
  res.on('data', chunk => ip += chunk);
  res.on('end', () => {
    console.log('\n========================================================');
    console.log(` PASSWORD IP (jika diminta di HP): ${ip.trim()}`);
    console.log('========================================================\n');
    startTunnel();
  });
});

req.on('error', () => {
  console.log('\n[INFO] Melanjutkan koneksi tunnel...');
  startTunnel();
});

req.on('timeout', () => {
  req.destroy();
  console.log('\n[INFO] Melanjutkan koneksi tunnel...');
  startTunnel();
});

function startTunnel() {
  console.log('Menghubungkan ke server tunnel...');
  console.log('URL publik kamu akan muncul di bawah (your url is: https://...):\n');

  const proc = spawn('npx', ['-y', 'localtunnel', '--port', '3000', '--local-host', '127.0.0.1'], {
    stdio: 'inherit',
    shell: true
  });

  proc.on('close', () => {
    console.log('\n[!] Tunnel terputus. Mencoba menghubungkan ulang otomatis dalam 3 detik...');
    setTimeout(startTunnel, 3000);
  });
}
