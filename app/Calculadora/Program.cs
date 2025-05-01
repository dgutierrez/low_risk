using Calculadora.Application.Feature.Soma.Interfaces;
using Calculadora.Application.Feature.Soma.UseCase;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpContextAccessor();
builder.Services.AddTransient<SomaUseCase>();
builder.Services.AddTransient<SomaUseCaseMock>();
builder.Services.AddTransient<ISomaUseCaseResolver, SomaUseCaseResolver>();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapHealthChecks("/");

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
