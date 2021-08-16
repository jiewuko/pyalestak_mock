from django.conf import settings
from django.contrib import admin
from django.conf.urls.static import static
from django.urls import path

from app.landing.views import HomePageView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', HomePageView.as_view(), name='index'),
]

urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
