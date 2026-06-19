from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from .models import Product
from .forms import ProductForm


def home(request):
    if not request.user.is_authenticated:
        return redirect("login")

    products = Product.objects.all().order_by("name")
    return render(request, "products/home.html", {"products": products})


@login_required
def product_create(request):
    if request.method == "POST":
        form = ProductForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect("home")
    else:
        form = ProductForm()
    return render(request, "products/product_form.html", {"form": form, "title": "Add Product"})


@login_required
def product_update(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == "POST":
        form = ProductForm(request.POST, instance=product)
        if form.is_valid():
            form.save()
            return redirect("home")
    else:
        form = ProductForm(instance=product)
    return render(request, "products/product_form.html", {"form": form, "title": "Edit Product"})


@login_required
def product_delete(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == "POST":
        product.delete()
        return redirect("home")
    return render(request, "products/product_confirm_delete.html", {"product": product})
