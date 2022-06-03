Rails.application.routes.draw do
  root "home#index"

  resources :events do
    patch :sync_event_with_google, on: :member
  end

  devise_for :users, :controllers => {
                       sessions: "users/sessions",
                       registrations: "users/registrations",
                       omniauth_callbacks: "users/omniauth_callbacks",
                     }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
