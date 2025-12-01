<template>
  <div class="min-h-screen relative flex items-center justify-center px-4">
    <!-- Fundo ilustrado -->
    <div
      class="absolute inset-0"
      :style="{
        backgroundImage: `url(${loginBg})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat',
      }"
    ></div>

    <!-- Overlay para dar contraste -->
    <div class="absolute inset-0 bg-gradient-to-b from-black/50 via-black/40 to-black/60"></div>

    <!-- Conteúdo -->
    <div class="relative z-10 w-full max-w-4xl">
      <div class="grid md:grid-cols-2 gap-8 items-center">
        <!-- Lado esquerdo: texto de destaque (desktop) -->
        <div
          class="hidden md:flex flex-col gap-4 text-base-100 bg-base-100/20 backdrop-blur-md border border-base-100/20 shadow-xl rounded-2xl p-6 animate-fadeIn"
        >
          <h2 class="text-3xl font-extrabold leading-tight drop-shadow-lg">
            Transforme problemas da cidade em ações concretas.
          </h2>

          <p class="text-sm text-base-100/80 max-w-md">
            O TerraON conecta cidadãos e gestão pública, centralizando denúncias, evidências e
            indicadores em um único lugar. Visualize pontos críticos da cidade e tome decisões com
            base em dados reais.
          </p>

          <div class="flex flex-wrap gap-2 mt-2 text-xs">
            <span class="badge badge-success badge-outline">Denúncias em tempo real</span>
            <span class="badge badge-warning badge-outline">Mapas e indicadores</span>
            <span class="badge badge-info badge-outline">Gestão centralizada</span>
          </div>
        </div>

        <!-- Card de login -->
        <div>
          <div
            class="card w-full shadow-2xl bg-base-100/90 border border-base-200/70 backdrop-blur-md"
          >
            <div class="card-body">
              <!-- Cabeçalho / logo -->
              <div class="flex flex-col items-center gap-4 mb-6">
                <div
                  class="w-28 h-28 rounded-full bg-base-200 flex items-center justify-center shadow-lg ring-4 ring-primary/70"
                >
                  <img
                    :src="logo"
                    alt="TerraON Logo"
                    class="w-24 h-24 object-contain drop-shadow-md"
                  />
                </div>

                <div class="text-center">
                  <h1 class="text-2xl font-extrabold text-primary tracking-wide">TerraON Portal</h1>
                  <p class="text-xs text-base-content/70 max-w-xs mx-auto">
                    Acesse o painel de gestão das denúncias e indicadores da cidade.
                  </p>
                </div>
              </div>

              <!-- Mensagem de erro -->
              <transition name="fade">
                <div v-if="error" class="alert alert-error text-xs mb-3">
                  <span>{{ error }}</span>
                </div>
              </transition>

              <!-- Formulário -->
              <form @submit.prevent="onSubmit" class="space-y-4">
                <label class="form-control w-full">
                  <div class="label">
                    <span class="label-text font-medium">E-mail</span>
                  </div>
                  <input
                    v-model="email"
                    type="email"
                    required
                    autocomplete="email"
                    placeholder="voce@exemplo.com"
                    class="input input-bordered w-full"
                  />
                </label>

                <label class="form-control w-full">
                  <div class="label">
                    <span class="label-text font-medium">Senha</span>
                  </div>
                  <input
                    v-model="password"
                    type="password"
                    required
                    autocomplete="current-password"
                    placeholder="••••••••"
                    class="input input-bordered w-full"
                  />
                </label>

                <div class="flex items-center justify-between text-xs">
                  <label class="cursor-pointer flex items-center gap-2">
                    <input type="checkbox" v-model="rememberMe" class="checkbox checkbox-xs" />
                    <span class="label-text">Lembrar de mim</span>
                  </label>

                  <button type="button" class="btn btn-ghost btn-xs normal-case text-primary">
                    Esqueci minha senha
                  </button>
                </div>

                <button
                  type="submit"
                  class="btn btn-primary w-full mt-2"
                  :disabled="loading"
                  :class="{ loading: loading }"
                >
                  <span v-if="!loading">Entrar</span>
                  <span v-else>Entrando...</span>
                </button>
              </form>

              <!-- Rodapé / versão -->
              <div class="mt-4 text-center text-[10px] text-base-content/60">
                TerraON · Portal de Gestão · v1.0
              </div>
            </div>
          </div>

          <!-- Texto mobile embaixo do card -->
          <div class="mt-4 md:hidden text-center text-xs text-base-100/80">
            Transformando denúncias em dados para uma cidade mais inteligente.
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { apiClient, setAuthToken } from '@/services/apiClient'
import { useAuthStore } from '@/stores/auth'
import logo from '@/assets/images/terraon-logo.png'
import loginBg from '@/assets/images/bg-login.png'

const email = ref('')
const password = ref('')
const rememberMe = ref(true)
const loading = ref(false)
const error = ref(null)

const router = useRouter()
const authStore = useAuthStore()

const onSubmit = async () => {
  if (loading.value) return

  loading.value = true
  error.value = null

  try {
    const res = await apiClient.post('api/login', {
      email: email.value,
      password: password.value,
    })

    const payload = res.data

    if (payload.statusCode !== 201) {
      throw new Error(payload.message || 'Falha ao autenticar.')
    }

    const user = payload.data

    if (!user || !user.accessToken) {
      throw new Error('Resposta de login inválida da API.')
    }

    console.log(user.accessToken)

    setAuthToken(user.accessToken)
    authStore.setUser(user)

    if (rememberMe.value) {
      localStorage.setItem('terraon_user', JSON.stringify(user))
    } else {
      localStorage.removeItem('terraon_user')
    }

    router.push({ name: 'dashboard' })
  } catch (err) {
    error.value =
      err?.response?.data?.message || err?.message || 'Não foi possível entrar. Tente novamente.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
