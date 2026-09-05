# 10 — Teardown & Migrasi (Archive Repo Lama, Kosongkan DB, Hapus 248 File)

Status: Final
Tanggal: 2026-09-02
Produk: Hiyuki — single-agent Discord
Bahasa: Indonesia
Referensi keputusan: ../decisions.md (D-09, D-62..D-66, D-88, D-146)
Dependensi dokumen: 03-architecture, 09-deployment-ops

---

## 1. Repo lama (D-09, D-62)

- Repo WWMA lama (`wuthering-waves-multi-agent`) → **archive read-only** di GitHub + git tag.
- Repo baru: `hiyuki-agent` (D-27, D-28), history fresh, nama beda.

## 2. DB lama (D-63, D-146)

- Semua tabel lama (34 tabel P12 + world/game/memory) → **DROP / buang total**.
- **TIDAK ada replacement** — Postgres dibuang total (D-146, supersedes D-87). Tidak ada Alembic, tidak ada DATABASE_URL, tidak ada tabel baru.
- Yang dipertahankan = fresh SQLite `state.db` Hermes + remote enowx-rag (lihat 03-architecture).

## 3. Redis (D-88)

- **Buang** — single agent cukup SQLite `state.db` Hermes.

## 4. Service lama (D-64)

Stop & nonaktifkan 6 service:
1. wwma-core
2. wwma-api
3. wwma-dashboard
4. wwma-gateway-hiyuki
5. wwma-gateway-suisui
6. openbao (→ dipertahankan sebagai vault? lihat §6)

## 5. Data P12 (D-66)

Buang semua data P12: wallet, browser, economy, identity, artifact, vault.

## 6. Vault / secret (D-65)

- **Pertahankan OpenBao/Vault** + sops/age encryption.
- age key di `/etc/gamesim/age.key` tetap.

## 7. Unit systemd lama

- Hapus/nonaktifkan: `wwma-gateway-*.service`, `gamesim-*.service`, `hermes-gateway-guinevere.service`.
- Ganti dengan single `hiyuki-gateway.service`.

## 8. Urutan teardown (aman)

1. Backup final state.db + SOUL asli (sebelum DROP).
2. Archive + tag repo lama (GitHub).
3. Stop 6 service lama + disable unit systemd.
4. Teardown Docker: `docker compose down -v` (Postgres + Redis + dashboard) → hapus container/volume/image dangling.
5. DROP database Postgres lama (atau hapus volume/container, tanpa replacement).
6. Hapus direktori `/opt/wwma` (repo lama + venv + build artifact + checkout Hermes lama).
7. Deploy repo baru ke `/opt/hiyuki` + single unit (fresh state.db).
8. Verifikasi bersih (lihat §9).
9. Verifikasi full-tool (G-DONE).

> Urutan detail per-fase ada di 14-implementation-plan dan 13-roadmap.

## 9. Pembersihan filesystem & Docker (bersih total)

Tujuan: VPS bersih total dari jejak WWMA lama — bukan cuma stop service, tapi hilangkan artefak disk.

| Artefak lama | Aksi | Keputusan |
|---|---|---|
| `/opt/wwma` (repo + venv + build) | `rm -rf /opt/wwma` | D-149 (path bersih `/opt/hiyuki`) |
| Docker container Postgres + Redis + dashboard | `docker compose -f /opt/wwma/docker-compose*.yml down -v` (sebelum rm) | D-146, D-88 |
| Volume/image Docker dangling | `docker system prune -a --volumes` (setelah down) | D-146, D-88 |
| Checkout Hermes lama (jika di luar /opt/wwma) | verifikasi lokasi saat F4, hapus jika ada | D-86 (Hermes = dependency baru) |
| Unit systemd lama | `wwma-gateway-*.service`, `gamesim-*.service`, `hermes-gateway-guinevere.service` | §7 |
| Data P12 (wallet/browser/...) | buang semua | D-66 |
| `$HERMES_HOME` lama | fresh: hapus `state.db` lama (686MB) + overwrite SOUL/OPS/config | F5 |

**Verifikasi bersih (G-TEARDOWN extend):**
1. `test ! -d /opt/wwma` → direktori lama hilang.
2. `docker ps -a | grep -E 'postgres|redis|wwma|dashboard'` → kosong.
3. `ss -tlnp | grep -E ':5432|:6379'` → tidak ada listener.
4. `systemctl list-units --all | grep -E 'wwma|gamesim|guinevere|openbao'` → hanya `openbao` tersisa (dipertahankan D-65).
5. `ls /opt` → hanya ada `hiyuki` (plus tailscale/openbao non-WWMA).
