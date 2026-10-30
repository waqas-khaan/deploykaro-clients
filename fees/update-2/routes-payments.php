// Update 2: a page listing the latest fee payments
Route::get('/payments', function () {
    $payments = \Illuminate\Support\Facades\DB::table('fee_payments')
        ->latest('paid_on')
        ->limit(20)
        ->get();

    return view('payment', ['payments' => $payments]);
});
