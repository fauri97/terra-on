// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

import LoginView from '@/views/LoginView.vue'
import AdminDashboardView from '@/views/AdminDashboardView.vue'
import PortalLayout from '@/layouts/AdminPortalLayout.vue'
import PrefeituraLayout from '@/layouts/PrefeituraLayout.vue'
import MunicipalDashboard from '@/views/MunicipalDashboard.vue'
import ReportsFeedView from '@/views/ReportsFeedView.vue'
import PostReportView from '@/views/AdminPostReportsView.vue'
import AdminUsersView from '@/views/AdminUsersView.vue'
import ReportsExportPage from '@/views/ReportsExportPage.vue'

const AdminSettingsView = {
  template: '<div>Configurações (em breve)</div>',
}

const routes = [
  {
    path: '/',
    name: 'login',
    component: LoginView,
    meta: {
      guestOnly: true,
      title: 'Login | TerraON',
    },
  },

  // =================== ADMIN ===================
  {
    path: '/admin',
    component: PortalLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard',
        component: AdminDashboardView,
        meta: { requiresAuth: true, title: 'Dashboard | TerraON' },
      },
      {
        path: 'reports',
        name: 'reports', // <-- IMPORTANTE: esse name EXISTE
        component: ReportsFeedView,
        meta: { requiresAuth: true, title: 'Denúncias | TerraON' },
      },
      {
        path: 'post-reports',
        name: 'post-reports',
        component: PostReportView,
        meta: { requiresAuth: true, title: 'Denúncias de Posts | TerraON' },
      },
      {
        path: 'users',
        name: 'users',
        component: AdminUsersView,
        meta: { requiresAuth: true, title: 'Usuários | TerraON' },
      },
      {
        path: 'reports/export',
        name: 'ReportsExport', // usado no layout de admin
        component: ReportsExportPage,
        meta: { requiresAuth: true, title: 'Relatórios | TerraON' },
      },
      {
        path: 'settings',
        name: 'settings',
        component: AdminSettingsView,
        meta: { requiresAuth: true, title: 'Configurações | TerraON' },
      },
    ],
  },

  // =================== PREFEITURA ===================
  {
    path: '/gov',
    component: PrefeituraLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'gov-dashboard' },
      },
      {
        path: 'dashboard',
        name: 'gov-dashboard',
        component: MunicipalDashboard,
        meta: { requiresAuth: true, title: 'Dashboard Prefeitura | TerraON' },
      },
      {
        path: 'reports',
        name: 'gov-reports', // usado no layout da prefeitura
        component: ReportsFeedView,
        meta: { requiresAuth: true, title: 'Denúncias | TerraON' },
      },
      {
        path: 'reports/export',
        name: 'gov-reports-export',
        component: ReportsExportPage,
        meta: { requiresAuth: true, title: 'Relatórios | TerraON' },
      },
    ],
  },

  // =================== 404 ===================
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: {
      template: `
        <div class="min-h-screen flex items-center justify-center bg-base-200">
          <div class="text-center space-y-4">
            <h1 class="text-3xl font-bold text-primary">404</h1>
            <p class="text-base-content/70">Página não encontrada.</p>
            <router-link to="/" class="btn btn-primary btn-sm mt-2">
              Ir para o início
            </router-link>
          </div>
        </div>
      `,
    },
    meta: {
      title: '404 | TerraON',
    },
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const isLoggedIn = authStore.isAuthenticated
  const role = (authStore.userRole || '').toLowerCase()

  if (to.meta && to.meta.title) {
    document.title = to.meta.title
  } else {
    document.title = 'TerraON Portal'
  }

  if (to.meta && to.meta.requiresAuth && !isLoggedIn) {
    return next({
      name: 'login',
      query: { redirect: to.fullPath },
    })
  }

  if (to.meta && to.meta.guestOnly && isLoggedIn) {
    if (role === 'admin') {
      return next({ name: 'dashboard' })
    }
    if (role === 'gov') {
      return next({ name: 'gov-dashboard' })
    }
    return next({ name: 'dashboard' })
  }

  return next()
})

export default router
