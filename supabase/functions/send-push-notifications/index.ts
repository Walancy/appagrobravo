import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../service-account.json' with { type: 'json' }

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
)

const asString = (value: unknown, fallback = ''): string => {
  if (value === null || value === undefined) return fallback
  return String(value)
}

const normalizeRoute = (value: unknown): string | null => {
  const route = asString(value).trim()
  if (!route || !route.startsWith('/')) return null
  return route
}

const getNotificationKind = (record: any): string => {
  return asString(record.assunto ?? record.tipo).toLowerCase().trim()
}

async function resolveTargetRoute(record: any): Promise<string> {
  const kind = getNotificationKind(record)
  const batepapoId = asString(record.batepapo_id).trim()
  const grupoId = asString(record.grupo_id).trim()
  const postId = asString(record.post_id).trim()

  console.log('[ROUTE_RESOLVE] kind=', kind, 'postId=', postId, 'batepapoId=', batepapoId, 'grupoId=', grupoId)

  // ── Chat de grupo ──────────────────────────────────────────────
  if (kind === 'chatgrupo' || kind === 'chat_grupo') {
    if (batepapoId) return `/chat-group/${batepapoId}`
    if (grupoId) return `/chat-group/${grupoId}`
    return '/home'
  }

  // ── Chat direto ────────────────────────────────────────────────
  if (kind === 'chatdireto' || kind === 'chat_direto') {
    if (batepapoId) return `/chat-direct/${batepapoId}`
    return '/home'
  }

  // ── Rota explícita do banco (fonte primária) ───────────────────
  // Todos os novos inserts definem target_route; usamos direto sem queries extras.
  const explicitRoute = normalizeRoute(record.target_route)
  if (explicitRoute) {
    console.log('[ROUTE_RESOLVE] using explicit target_route=', explicitRoute)
    return explicitRoute
  }

  // ── Fallbacks para notificações legadas (sem target_route) ────

  // Social: Likes, Comentários, Menções → /user-feed/:postOwnerId?postId=:postId
  const isPostInteraction =
    kind.includes('curtiu') ||
    kind.includes('like') ||
    kind.includes('comentou') ||
    kind.includes('comment') ||
    kind.includes('mencionou') ||
    kind.includes('mention')

  if (isPostInteraction && postId) {
    try {
      const { data: post, error } = await supabase
        .from('posts')
        .select('user_id')
        .eq('id', postId)
        .maybeSingle()

      if (!error && post?.user_id) {
        const route = `/user-feed/${post.user_id}?postId=${postId}`
        console.log('[ROUTE_RESOLVE] legacy post interaction route=', route)
        return route
      }
    } catch (e) {
      console.error('[ROUTE_RESOLVE] error fetching post owner:', e)
    }
    return '/home'
  }

  // Follow / Conexão → /connections/:userId?initialIndex=1
  const isFollowKind =
    kind.includes('follow') ||
    kind.includes('conexão') ||
    kind.includes('conexao') ||
    kind.includes('solicitação') ||
    kind.includes('solicitacao') ||
    kind.includes('seguir')
  const hasSolicitacaoUser = asString(record.solicitacao_user_id).trim()

  if (isFollowKind || hasSolicitacaoUser) {
    const recipientId = asString(record.user_id).trim()
    if (recipientId) return `/connections/${recipientId}?initialIndex=1`
    return '/home'
  }

  // ── Documentos ─────────────────────────────────────────────────
  if (record.doc_id) return '/documents'

  // ── Missão/itinerário → aba de itinerário na HomePage (tab 0) ──
  if (grupoId) {
    const route = `/home?tab=0&groupId=${grupoId}`
    console.log('[ROUTE_RESOLVE] fallback itinerary route=', route)
    return route
  }

  // Último fallback → home, NUNCA /notifications
  return '/home'
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405)
  }

  let payload: any
  try {
    payload = await req.json()
  } catch {
    return json({ error: 'Invalid JSON payload' }, 400)
  }

  const record = payload.record ?? payload

  console.log('[FULL_PAYLOAD]', JSON.stringify(payload))
  console.log('[RECORD]', JSON.stringify(record))

  const userId = asString(record.user_id ?? record.recipient_id).trim()
  const title = asString(record.titulo ?? record.title, 'AgroBravo')
  const body = asString(record.mensagem ?? record.body)
  const targetRoute = await resolveTargetRoute(record)

  console.log('[RESOLVED]', JSON.stringify({
    userId,
    title,
    targetRoute,
    assunto: record.assunto,
    tipo: record.tipo,
    batepapo_id: record.batepapo_id,
    grupo_id: record.grupo_id,
    target_route_raw: record.target_route,
  }))

  if (!userId) {
    return json({ error: 'No user ID found', keys: Object.keys(record ?? {}) }, 400)
  }

  try {
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, fcm_token, notificacoes_push, email, notificacoes_email')
      .eq('id', userId)
      .maybeSingle()

    if (userError || !user) {
      console.error('[USER_LOOKUP_ERROR]', userError)
      return json({ error: 'User not found', detail: userError?.message }, 404)
    }

    await sendEmailIfEnabled({
      user,
      title,
      body,
      notificationId: asString(record.id),
    })

    if (user.notificacoes_push === false) {
      return json({ ok: true, skipped: 'push_disabled' })
    }

    if (!user.fcm_token) {
      return json({ ok: true, skipped: 'missing_fcm_token' })
    }


    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    })

    const fcmPayload = {
      message: {
        token: user.fcm_token,
        notification: {
          title,
          body,
        },
        data: {
          target_route: targetRoute,
          notification_id: asString(record.id),
          tipo: asString(record.tipo),
          assunto: asString(record.assunto),
          batepapo_id: asString(record.batepapo_id),
          grupo_id: asString(record.grupo_id),
          post_id: asString(record.post_id),
          doc_id: asString(record.doc_id),
          missao_id: asString(record.missao_id),
          solicitacao_user_id: asString(record.solicitacao_user_id),
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channel_id: 'default',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      },
    }

    console.log('[FCM_PAYLOAD_DATA]', JSON.stringify(fcmPayload.message.data))

    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(fcmPayload),
      },
    )

    const fcmData = await safeJson(fcmResponse)
    console.log('[FCM_RESPONSE]', fcmResponse.status, JSON.stringify(fcmData))

    if (!fcmResponse.ok) {
      if (isInvalidFcmToken(fcmData)) {
        await supabase
          .from('users')
          .update({ fcm_token: null })
          .eq('id', userId)

        console.warn('[FCM_TOKEN_CLEARED]', userId)
      }

      return json({
        error: 'FCM error',
        status: fcmResponse.status,
        detail: fcmData,
      }, 502)
    }

    return json({
      ok: true,
      target_route: targetRoute,
      fcm: fcmData,
    })
  } catch (e) {
    console.error('[UNHANDLED_ERROR]', e)
    return json({
      error: e instanceof Error ? e.message : String(e),
    }, 500)
  }
})

async function sendEmailIfEnabled({
  user,
  title,
  body,
  notificationId,
}: {
  user: any
  title: string
  body: string
  notificationId: string
}) {
  const emailWebhookUrl = Deno.env.get('EMAIL_WEBHOOK_URL')
  const emailEnabled = user.notificacoes_email === true && user.email

  if (!emailWebhookUrl || !emailEnabled) return

  try {
    await fetch(emailWebhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        to: user.email,
        subject: title,
        body,
        notification_id: notificationId,
      }),
    })
  } catch (e) {
    console.error('[EMAIL_ERROR]', e instanceof Error ? e.message : String(e))
  }
}

async function safeJson(response: Response) {
  const text = await response.text()
  try {
    return JSON.parse(text)
  } catch {
    return { raw: text }
  }
}

function isInvalidFcmToken(fcmData: any): boolean {
  const serialized = JSON.stringify(fcmData).toUpperCase()
  return (
    serialized.includes('UNREGISTERED') ||
    serialized.includes('INVALID_ARGUMENT') ||
    serialized.includes('REGISTRATION_TOKEN_NOT_REGISTERED')
  )
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
    },
  })
}

function getAccessToken({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })

    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }

      const accessToken = tokens?.access_token
      if (!accessToken) {
        reject(new Error('Google access token not returned'))
        return
      }

      resolve(accessToken)
    })
  })
}
