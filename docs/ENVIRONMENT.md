# Environment Manifest — Ojoro

Store metadata only. Never commit secret values.

| Variable / capability | Source | Status | Environments | Client-visible | Owner |
|---|---|---|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project metadata | available | CI, preview, production | yes | DevOps |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Supabase publishable key | available | preview, production | yes | DevOps |
| Supabase authenticated user session | Supabase Auth cookie | implemented | preview, production | session only | Backend |
| Vercel project | Vercel team | not created yet | preview, production | n/a | DevOps |
| Production custom domain | DNS/Vercel | not configured | production | yes | Product owner |
| Calendar provider OAuth | future provider credentials | not required | future | no | Integrations |
| Wearable provider credentials | future provider credentials | not required | future | no | Integrations |

## Deployment targets

- **Database / Auth:** existing Supabase project `Ojoro Command Centre`, project ref `iddujjsbyytwbrvqsxrg`, Canada Central. Consumer product objects are namespaced `oj_*`; legacy Command Centre objects remain untouched.
- **Web:** Next.js app under `apps/ojoro-web`, intended Vercel project with root directory `apps/ojoro-web`.
- **CI:** GitHub Actions workflow `.github/workflows/ojoro-web.yml` on `product/ojoro-platform` and pull requests.

## Environment parity

The same Next.js application artifact is used for preview and production. Environment-specific behavior is limited to Supabase endpoint/publishable credentials and deployment URL. Database changes are migration-backed under `supabase/migrations/` and are applied before application promotion.

## Standing command authorization

See `config/authorized-commands.yaml`. Production database deletion/reset is not authorized by the build request and is not used by Ojoro migrations.
