<template>
  <div class="drawer lg:drawer-open min-h-screen bg-base-200">
    <!-- toggle do drawer (mobile) -->
    <input id="sidebar-toggle" type="checkbox" class="drawer-toggle" />

    <!-- CONTEÚDO PRINCIPAL -->
    <div class="drawer-content flex flex-col">
      <!-- Topbar -->
      <header class="w-full navbar bg-base-100 shadow-sm px-4 lg:px-6">
        <div class="flex-none lg:hidden">
          <label
            for="sidebar-toggle"
            class="btn btn-ghost btn-square"
            aria-label="Abrir menu lateral"
          >
            <span class="flex flex-col items-center justify-center gap-[3px]" aria-hidden="true">
              <span class="w-4 h-0.5 rounded-full bg-base-content"></span>
              <span class="w-4 h-0.5 rounded-full bg-base-content"></span>
              <span class="w-4 h-0.5 rounded-full bg-base-content"></span>
            </span>
          </label>
        </div>

        <div class="flex-1">
          <h1 class="text-lg lg:text-xl font-semibold text-base-content">
            {{ pageTitle }}
          </h1>
          <p class="text-xs text-base-content/70 hidden sm:block">
            TerraON · Painel administrativo
          </p>
        </div>

        <div class="flex-none flex items-center gap-3">
          <div class="text-right hidden sm:block">
            <div class="text-sm font-medium">
              {{ authStore.userName || 'Administrador' }}
            </div>
            <div class="text-[11px] text-base-content/60">
              {{ authStore.userEmail || 'admin@terraon.app' }}
            </div>
          </div>

          <div class="dropdown dropdown-end">
            <label tabindex="0" class="btn btn-ghost btn-circle avatar">
              <div class="w-9 rounded-full border border-base-300">
                <img v-if="authStore.userAvatarSrc" :src="authStore.userAvatarSrc" alt="Avatar" />
                <div
                  v-else
                  class="w-full h-full flex items-center justify-center bg-primary text-primary-content text-xs font-bold"
                >
                  {{ initials }}
                </div>
              </div>
            </label>
            <ul
              tabindex="0"
              class="mt-3 z-50 p-2 shadow menu menu-sm dropdown-content bg-base-100 rounded-box w-52"
            >
              <li class="menu-title text-xs">Conta</li>
              <li>
                <button type="button">Perfil (em breve)</button>
              </li>
              <li>
                <button type="button" @click="handleLogout">Sair</button>
              </li>
            </ul>
          </div>
        </div>
      </header>

      <!-- Conteúdo -->
      <main class="flex-1 p-4 lg:p-6 overflow-y-auto">
        <RouterView />
      </main>
    </div>

    <!-- SIDEBAR -->
    <div class="drawer-side">
      <label for="sidebar-toggle" class="drawer-overlay"></label>

      <aside
        class="w-72 bg-base-100 text-base-content border-r border-base-200 flex flex-col min-h-screen"
      >
        <!-- Logo / título -->
        <div class="flex items-center gap-3 px-4 py-4 border-b border-base-200">
          <div class="w-10 h-10 rounded-full bg-base-200 flex items-center justify-center">
            <img :src="logo" alt="TerraON Logo" class="w-9 h-9 object-contain" />
          </div>
          <div>
            <div class="font-bold text-base">TerraON Portal</div>
            <div class="text-[11px] text-base-content/60">Administração</div>
          </div>
        </div>

        <nav class="flex-1 overflow-y-auto py-4">
          <ul class="px-3 space-y-5 text-sm">
            <!-- VISÃO GERAL -->
            <li>
              <p
                class="text-[11px] font-semibold tracking-wider uppercase text-base-content/50 mb-2"
              >
                Visão geral
              </p>
              <ul class="space-y-1">
                <li>
                  <RouterLink :to="{ name: 'dashboard' }" :class="menuItem('dashboard')">
                    <span class="material-symbols-outlined text-lg">dashboard</span>
                    <span>Dashboard</span>
                  </RouterLink>
                </li>
              </ul>
            </li>

            <!-- CONTEÚDO -->
            <li>
              <p
                class="text-[11px] font-semibold tracking-wider uppercase text-base-content/50 mb-2"
              >
                Conteúdo
              </p>
              <ul class="space-y-1">
                <li>
                  <RouterLink :to="{ name: 'reports' }" :class="menuItem('reports')">
                    <span class="material-symbols-outlined text-lg">post</span>
                    <span>Denúncias</span>
                  </RouterLink>
                </li>

                <li>
                  <RouterLink :to="{ name: 'cities' }" :class="menuItem('cities')">
                    <span class="material-symbols-outlined text-lg">report</span>
                    <span>Denúncias de Posts</span>
                  </RouterLink>
                </li>
              </ul>
            </li>

            <!-- ADMINISTRAÇÃO -->
            <li>
              <p
                class="text-[11px] font-semibold tracking-wider uppercase text-base-content/50 mb-2"
              >
                Administração
              </p>
              <ul class="space-y-1">
                <li>
                  <RouterLink :to="{ name: 'users' }" :class="menuItem('users')">
                    <span class="material-symbols-outlined text-lg">group</span>
                    <span>Usuários</span>
                  </RouterLink>
                </li>

                <li>
                  <RouterLink :to="{ name: 'settings' }" :class="menuItem('settings')">
                    <span class="material-symbols-outlined text-lg">settings</span>
                    <span>Configurações</span>
                  </RouterLink>
                </li>
              </ul>
            </li>
          </ul>
        </nav>

        <!-- Rodapé -->
        <div class="px-4 py-3 border-t border-base-200 text-[11px] text-base-content/60">
          TerraON · v1.0<br />
          <span class="opacity-70">Painel de gestão de denúncias</span>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter, RouterLink, RouterView } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import logo from '@/assets/images/terraon-logo.png'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const pageTitle = computed(() => {
  const map = {
    dashboard: 'Dashboard',
    reports: 'Denúncias',
    cities: 'Cidades',
    users: 'Usuários',
    settings: 'Configurações',
  }
  return map[route.name] || 'TerraON'
})

const menuItem = (name) => {
  const active = route.name === name

  return [
    'flex items-center gap-3 px-3 py-2 rounded-lg transition-colors select-none',
    active
      ? 'bg-primary/15 text-primary font-semibold'
      : 'hover:bg-base-200 hover:text-base-content/100 text-base-content/80',
  ]
}

const initials = computed(() => {
  const name = authStore.userName || 'Admin TerraON'
  const parts = name.trim().split(' ')
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase()
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
})

const handleLogout = () => {
  authStore.logout()
  router.push({ name: 'login' })
}
</script>
