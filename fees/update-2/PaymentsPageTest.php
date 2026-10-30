<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class PaymentsPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_the_payments_page_lists_payments(): void
    {
        DB::table('fee_payments')->insert([
            'student_name' => 'Test Student',
            'class_name' => '5-A',
            'amount' => 3000,
            'paid_on' => '2026-10-01',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->get('/payments');

        $response->assertStatus(200);
        $response->assertSee('Test Student');
    }
}
